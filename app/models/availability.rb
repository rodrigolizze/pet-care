class Availability < ApplicationRecord
  belongs_to :user

  has_many :bookings, dependent: :destroy

  validates :date, presence: true
end
