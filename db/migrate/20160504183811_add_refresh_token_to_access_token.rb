class AddRefreshTokenToAccessToken < ActiveRecord::Migration
  def change
    add_reference :access_tokens, :refresh_token, index: true
  end
end
