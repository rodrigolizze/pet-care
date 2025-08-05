class Booking < ApplicationRecord
  belongs_to :availability
  belongs_to :user

  validates :pet_name, :animal_type, :pet_size, :pet_birth_year, presence: true
end
