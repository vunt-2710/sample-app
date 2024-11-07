class User < ApplicationRecord
  PERMITTED_PARAMS = [:name, :email, :password, :password_confirmation].freeze
  RESET_PASSWORD_PARAMS = [:password, :password_confirmation].freeze

  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
            foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
            foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  validates :name,
            presence: true,
            length: {maximum: Settings.default.userName.maxLength}

  validates :email,
            presence: true,
            length: {maximum: Settings.default.email.maxLength},
            format: {with: Regexp.new(Settings.default.email.format,
                                      Regexp::IGNORECASE)},
            uniqueness: {case_sensitive: false}

  validates :password,
            presence: true,
            length: {minimum: Settings.default.password.minLength},
            on: %i(create password_reset)

  validates :password,
            length: {minimum: Settings.default.password.minLength},
            allow_nil: true,
            on: :update

  before_save :downcase_email
  before_create :create_activation_digest
  has_secure_password
  attr_accessor :remember_token, :activation_token, :reset_token

  class << self
    def new_token
      SecureRandom.urlsafe_base64
    end

    def digest string
      cost =
        if ActiveModel::SecurePassword.min_cost
          BCrypt::Engine::MIN_COST
        else
          BCrypt::Engine.cost
        end
      BCrypt::Password.create(string, cost:)
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  def forget
    update_column :remember_digest, nil
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def password_reset_token_expired?
    reset_sent_at < Settings.default.resetToken.expiration.hours.ago
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def feed
    Micropost.relate_post(following_ids << id)
             .includes(:user, image_attachment: :blob)
  end

  def follow other_user
    following << other_user
  end

  def unfollow other_user
    following.delete other_user
  end

  def following? other_user
    following.include? other_user
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end
end
