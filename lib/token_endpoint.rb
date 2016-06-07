class TokenEndpoint
  attr_accessor :app
  delegate :call, to: :app

  def initialize
    @app = Rack::OAuth2::Server::Token.new do |req, res|
      client = Client.find_by_identifier(req.client_id) || req.invalid_client!
      client.secret == req.client_secret || req.invalid_client!
      case req.grant_type
        when :client_credentials
          # NOTE: client is already authenticated here.
          res.access_token = client.access_tokens.create!.to_bearer_token
        when :authorization_code
          authorization = client.authorizations.valid.find_by_code(req.code)
          req.invalid_grant! if authorization.blank? || !authorization.valid_redirect_uri?(req.redirect_uri)
          access_token_bearer = authorization.access_token.to_bearer_token(:with_refresh_token)
          res.access_token = access_token_bearer
          access_token = AccessToken.find_by(token: access_token_bearer.access_token)
          res.id_token = access_token.account.id_tokens.create!(
              client: access_token.client,
              nonce: authorization.nonce,
              request_object: authorization.request_object
          ).to_jwt
        when :password
          User.authenticate(req.username, req.password) || req.invalid_grant!
          account = User.find_by_email(req.username).account
          access_token_bearer = account.access_tokens.create(:client => client).to_bearer_token(:with_refresh_token)
          res.access_token = access_token_bearer
          access_token = AccessToken.find_by(token: access_token_bearer.access_token)
          res.id_token = access_token.account.id_tokens.create!(
              client: access_token.client
          ).to_jwt
        when :refresh_token
          refresh_token = client.refresh_tokens.valid.find_by_token(req.refresh_token)
          req.invalid_grant! unless refresh_token
          res.access_token = refresh_token.access_tokens.create.to_bearer_token
        else
          req.unsupported_grant_type!
      end
    end
  end
end