class Booking < ApplicationRecord
  belongs_to :availability
  belongs_to :user

  validates :pet_name, :animal_type, :pet_size, :pet_birth_year, presence: true

  validate :availability_must_be_free

  private

  def availability_must_be_free
    return if availability_id.blank?
    # Look for any other booking for this availability (exclude self)
    if Booking.where(availability_id: availability_id).where.not(id: id).exists?
      errors.add(:availability, "já foi reservada.")
    end
  end
end
