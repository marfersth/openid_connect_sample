class UsersController < ApplicationController
  before_filter :require_anonymous_access

  def create
    valid = (user = User.find_by_email(user_params[:email])).try(:valid_password?, user_params[:password])
    raise AuthenticationRequired.new unless valid
    authenticate user.authenticate
    logged_in!
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end