class User < ApplicationRecord
  PERMITTED_PARAMS = [:name, :email, :password, :password_confirmation].freeze

  before_save :downcase_email

  validates :name,
            presence: true,
            length: {maximum: Settings.default.userName.maxLength}
  validates :email, presence: true,
                    length: {maximum: Settings.default.email.maxLength},
                    format: {with: Regexp.new(Settings.default.email.format,
                                              Regexp::IGNORECASE)},
                    uniqueness: {case_sensitive: false}

  has_secure_password

  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create(string, cost:)
  end

  private

  def downcase_email
    email.downcase!
  end
end
