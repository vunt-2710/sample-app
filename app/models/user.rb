class User < ApplicationRecord
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

  private

  def downcase_email
    email.downcase!
  end
end
