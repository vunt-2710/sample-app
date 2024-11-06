class Micropost < ApplicationRecord
  PERMITTED_PARAMS = [:content, :image].freeze

  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display,
                       resize_to_limit: Settings.default.image.size
  end

  allow_image_type = Settings.default.image.type&.split(", ")

  validates :content,
            presence: true,
            length: {maximum: Settings.default.micropost.maxLength}

  validates :image,
            content_type: {in: allow_image_type,
                           message: I18n.t("activerecord.errors.image.type")},
            size: {less_than: Settings.default.image.maxSize.megabytes,
                   message: I18n.t("activerecord.errors.image.size")}

  scope :newest, ->{order created_at: :desc}
  scope :relate_post, ->(user_ids){where user_id: user_ids}
end
