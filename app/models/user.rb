class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable

  # Relationships
  has_many :availabilities, dependent: :destroy
  has_many :bookings, dependent: :destroy

  # Roles: sitter or client
  enum role: { client: 'client', sitter: 'sitter' }

  validates :name, :role, :cpf, presence: true
  validates :cpf, uniqueness: true
end
