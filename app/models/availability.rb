class Availability < ApplicationRecord
  belongs_to :user

  has_many :bookings, dependent: :destroy

  validates :date, presence: true

  def already_booked?
    bookings.exists?
  end
end
