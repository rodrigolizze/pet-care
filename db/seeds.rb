# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Reset database
Booking.destroy_all
Availability.destroy_all
User.destroy_all

puts "Criando usuários..."

users = []

10.times do |i|
  role = i < 2 ? "sitter" : "client"

  users << User.create!(
    name: "Usuário #{i + 1}",
    address: "Rua Exemplo, nº #{i + 10}",
    role: role,
    birth_date: Date.new(1990, 1, i + 1),
    cpf: "000.000.000-0#{i}",
    email: "user#{i}@example.com",        # Required by Devise
    password: "password123",              # Required by Devise
    password_confirmation: "password123"  # Optional but good practice
  )
end

puts "Criando disponibilidades para sitters..."

availabilities = []

sitter_users = users.select { |u| u.role == "sitter" }

sitter_users.each_with_index do |sitter, index|
  5.times do |j|
    availabilities << Availability.create!(
      user: sitter,
      date: Date.today + (index * 5 + j).days
    )
  end
end

puts "Criando reservas (bookings)..."

15.times do |i|
  availability = availabilities.sample
  guest_user = users.select { |u| u.role == "client" }.sample

  Booking.create!(
    availability: availability,
    user: guest_user,
    pet_name: "Pet #{i + 1}",
    animal_type: %w[dog cat bird rabbit].sample,
    pet_size: %w[small medium large].sample,
    pet_birth_year: rand(2015..2023)
  )
end

puts "✅ Seeds criados com sucesso!"
