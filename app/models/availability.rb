class Availability < ApplicationRecord
  belongs_to :user

  has_one :booking, dependent: :destroy

  scope :future,   -> { where("date >= ?", Date.current) }
  scope :unbooked, -> { left_outer_joins(:booking).where(bookings: { id: nil }) }
  scope :ordered,  -> { order(:date) }

  validates :date, presence: true
  validates :date, uniqueness: { scope: :user_id, message: "já existe para este cuidador" }
  validate  :date_cannot_be_in_the_past

  private

  def date_cannot_be_in_the_past
    return if date.blank?
    if date < Date.current
      errors.add(:date, "não pode ser no passado")
    end
  end
end
