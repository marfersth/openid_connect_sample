class User < ActiveRecord::Base
  belongs_to :account

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  validates :email, uniqueness: true, presence: true, email: true

  def userinfo
    OpenIDConnect::ResponseObject::UserInfo.new(
        name:         'Fake Account',
        email:        email,
        address:      'Shibuya, Tokyo, Japan',
        profile:      'http://example.com/fake',
        locale:       'en_US',
        phone_number: '+81 (3) 1234 5678',
        verified: true
    )
  end

  def self.authenticate(email, password)
    User.find_by_email(email).try(:valid_password?, password)
  end

  def create_account
    Account.create!(user: self)
  end
end
