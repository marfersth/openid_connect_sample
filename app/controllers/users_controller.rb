class UsersController < ApplicationController
  before_filter :require_anonymous_access

  def create
    valid = User.authenticate(user_params[:email], user_params[:password])
    raise AuthenticationRequired.new unless valid
    user = User.find_by_email(user_params[:email])
    authenticate user.authenticate
    logged_in!
  end

  private

  def user_params
    params.require(:user).permit(:email, :password)
  end
end