class Availability < ApplicationRecord
  belongs_to :user

  has_one :booking, dependent: :destroy

  validates :date, presence: true

  def already_booked?
    bookings.exists?
  end
end
