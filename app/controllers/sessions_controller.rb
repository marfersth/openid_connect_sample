class SessionsController < ApplicationController
  before_filter :require_authentication

  def destroy
    redirect_url = AccessToken.find_by(account_id: current_account.try(:id))
                       .try(:client).try(:redirect_uris).try(:first)
    unauthenticate!
    redirect_to redirect_url || root_url
  end

  def create
    # devise create action
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)

    authenticate self.resource.create_account
    logged_in!
  end
end
