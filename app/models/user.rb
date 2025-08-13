class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  # Relationships
  has_many :availabilities, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_one_attached :photo

  # Roles: sitter or client
  # enum role: { client: 'client', sitter: 'sitter' }
  PROPERTY_TYPES = %w[house apartment].freeze
  ANIMAL_SIZES = %w[small medium big all].freeze

  validates :property_type, inclusion: { in: PROPERTY_TYPES }, allow_nil: true
  validates :animal_sizes, inclusion: { in: ANIMAL_SIZES }, allow_nil: true

  validates :name, :cpf, :photo, :city, presence: true
  # validates :cpf, uniqueness: true
  validates :cpf, uniqueness: { case_sensitive: false, scope: [], message: "já está em uso" }
end
