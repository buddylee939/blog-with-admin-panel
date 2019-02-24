class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :visitor
  has_many :notifications, as: :notifiable, dependent: :destroy

  validates :message, presence: true

  scope :approved, -> { where status: true }

  def self.matching_fullname_or_message params
    joins(:visitor).where("fullname LIKE ? OR message LIKE ?", "%#{params}%", "%#{params}%")
  end
  
  include Notifiable  
end

