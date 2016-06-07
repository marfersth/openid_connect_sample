class AccessToken < ActiveRecord::Base
  include Oauth2Token
  self.default_lifetime = 6.hours
  belongs_to :refresh_token
  has_many :access_token_scopes
  has_many :scopes, through: :access_token_scopes
  has_one :access_token_request_object
  has_one :request_object, through: :access_token_request_object

  def to_bearer_token(with_refresh_token = false)
    bearer_token = Rack::OAuth2::AccessToken::Bearer.new(
        :access_token => self.token,
        :expires_in => self.expires_in
    )
    if with_refresh_token
      bearer_token.refresh_token = self.create_refresh_token(
          :account => self.account,
          :client => self.client
      ).token
    end
    bearer_token
  end

  def accessible?(_scopes_or_claims_ = nil)
    claims = request_object.try(:to_request_object).try(:userinfo)
    Array(_scopes_or_claims_).all? do |_scope_or_claim_|
      case _scope_or_claim_
      when Scope
        scopes.include? _scope_or_claim_
      else
        claims.try(:accessible?, _scope_or_claim_)
      end
    end
  end

  private

  def setup
    super
    if refresh_token
      self.account = refresh_token.account
      self.client = refresh_token.client
      self.expires_at = [self.expires_at, refresh_token.expires_at].min
    end
  end
end
