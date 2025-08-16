# db/seeds.rb
# frozen_string_literal: true

require "securerandom"
require "open-uri"
require "stringio"
require "digest"
require "cgi"
require "base64"

puts "==> Purging data…"
Booking.delete_all
Availability.delete_all
if defined?(ActiveStorage::Attachment)
  ActiveStorage::Attachment.delete_all
  ActiveStorage::Blob.delete_all
end
User.delete_all
puts "…done."

# ------------------------ Helpers ------------------------

# Tiny valid 1x1 JPEG (base64). Fallback if the internet hiccups.
ONE_BY_ONE_GIF = Base64.decode64("R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==")

def attach_fallback_image(record, name:, filename: "fallback.gif")
  record.public_send(name).attach(
    io: StringIO.new(ONE_BY_ONE_GIF),
    filename: filename,
    content_type: "image/gif"
  )
end

# Robust remote attach: try URL; if it fails, attach 1x1 GIF
def attach_from_url(record, name, url, filename: nil)
  begin
    io = URI.open(url, open_timeout: 5, read_timeout: 10, "User-Agent" => "Mozilla/5.0")
    fn = filename || File.basename(URI.parse(url).path.presence || "image.jpg")
    ct = io.content_type || "image/jpeg"
    ct = "image/jpeg" if ct == "image/jpg"
    record.public_send(name).attach(io: io, filename: fn, content_type: ct)
    true
  rescue => e
    puts "  -> failed #{url}: #{e.class} #{e.message}"
    attach_fallback_image(record, name: name)
    false
  end
end

# Avatars (stable + you already confirmed OK)
def avatar_urls_for(user)
  h   = Digest::SHA1.hexdigest(user.email.to_s)
  id  = (h[0..1].to_i(16) % 99) + 1 # 1..99
  sex = (h[2..3].to_i(16).odd? ? "women" : "men")
  [
    "https://randomuser.me/api/portraits/#{sex}/#{id}.jpg",
    "https://randomuser.me/api/portraits/men/#{id}.jpg",
    "https://randomuser.me/api/portraits/women/#{id}.jpg"
  ]
end

# Super-reliable sitter gallery images: placehold.co JPEGs with a nice label.
PLACE_COLORS = [
  %w[10b981 ffffff], # emerald / white
  %w[6366f1 ffffff], # indigo  / white
  %w[f59e0b 111827], # amber   / slate-900
  %w[ef476f ffffff]  # rose    / white
].freeze

def place_image_url(index)
  colors = PLACE_COLORS[index % PLACE_COLORS.size]
  text   = CGI.escape("Tutor & Pet ##{index}")
  # Explicit .jpg to guarantee JPEG content-type
  "https://placehold.co/1200x800/#{colors[0]}/#{colors[1]}.jpg?text=#{text}"
end

def cpf_from_seq(n)
  s = format("%011d", n)
  "#{s[0..2]}.#{s[3..5]}.#{s[6..8]}-#{s[9..10]}"
end

CITIES = [
  { city: "São Paulo",      address_samples: ["Av. Paulista, 1000", "Rua Augusta, 250", "Rua Oscar Freire, 320"] },
  { city: "Rio de Janeiro", address_samples: ["Av. Atlântica, 200", "Rua das Laranjeiras, 45", "Rua Visconde de Pirajá, 700"] },
  { city: "Belo Horizonte", address_samples: ["Av. Afonso Pena, 900", "Rua da Bahia, 120", "Savassi, 55"] },
  { city: "Curitiba",       address_samples: ["Batel, 88", "Centro Cívico, 12", "Rua XV de Novembro, 300"] },
  { city: "Porto Alegre",   address_samples: ["Moinhos de Vento, 40", "Cidade Baixa, 210", "Av. Ipiranga, 1200"] }
].freeze

PROPERTY_TYPES = User::PROPERTY_TYPES
ANIMAL_SIZES   = User::ANIMAL_SIZES
ANIMAL_TYPES   = %w[Cachorro Gato Coelho Pássaro].freeze
PET_SIZES_PT   = { "small" => "Pequeno", "medium" => "Médio", "big" => "Grande" }.freeze

def rand_phone_br
  ddd = %w[11 21 31 41 51 61].sample
  "55#{ddd}9#{rand(1000..9999)}#{rand(1000..9999)}"
end

def pick_city_address
  c = CITIES.sample
  [c[:city], c[:address_samples].sample]
end

# ------------------------ Seed data ------------------------

users = []

puts "==> Creating fixed test users…"
# Demo sitter
city, addr = pick_city_address
u1 = User.new(
  email: "sitter@petcare.test",
  password: "123456",
  name: "Sitter Demo",
  address: addr,
  city: city,
  cpf: cpf_from_seq(1),
  telephone: rand_phone_br,
  sitter: true,
  client: true,
  property_type: PROPERTY_TYPES.sample,
  backyard: [true, false].sample,
  has_pet: [true, false].sample,
  screened_windows: [true, false].sample,
  animal_sizes: ANIMAL_SIZES.sample,
  bio: "Cuidador apaixonado por animais, experiência com rotina de passeios e hospedagem.",
  experience: "2 anos com cães de pequeno e médio porte. Referências disponíveis."
)
# Avatar
attach_from_url(u1, :photo, avatar_urls_for(u1).first)
u1.save!

# Gallery (3 reliable JPEGs)
3.times { |i| attach_from_url(u1, :place_photos, place_image_url(i + 1), filename: "place_#{i + 1}.jpg") }
users << u1

# Demo client
city, addr = pick_city_address
u2 = User.new(
  email: "client@petcare.test",
  password: "123456",
  name: "Cliente Demo",
  address: addr,
  city: city,
  cpf: cpf_from_seq(2),
  telephone: rand_phone_br,
  sitter: false,
  client: true
)
attach_from_url(u2, :photo, avatar_urls_for(u2).first)
u2.save!
users << u2

puts "==> Creating random sitters…"
sitter_count = 10
(1..sitter_count).each do |i|
  city, addr = pick_city_address
  u = User.new(
    email: "sitter#{i}@petcare.test",
    password: "123456",
    name: ["Ana", "Bruno", "Carla", "Diego", "Elaine", "Felipe", "Gabi", "Hugo", "Isabela", "João", "Karen", "Luan"].sample + " #{%w[Silva Sousa Oliveira Pereira Gomes Rodrigues].sample}",
    address: addr,
    city: city,
    cpf: cpf_from_seq(100 + i),
    telephone: rand_phone_br,
    sitter: true,
    client: [true, false].sample,
    property_type: PROPERTY_TYPES.sample,
    backyard: [true, false].sample,
    has_pet: [true, false].sample,
    screened_windows: [true, false].sample,
    animal_sizes: ANIMAL_SIZES.sample,
    bio: "Amo animais! Ofereço hospedagem com carinho e passeios diários.",
    experience: ["1 ano", "2 anos", "3 anos", "5 anos"].sample + " de experiência com cães e gatos."
  )
  attach_from_url(u, :photo, avatar_urls_for(u).first)
  u.save!

  # 2–4 gallery images per sitter
  rand(2..4).times do |k|
    attach_from_url(u, :place_photos, place_image_url(k + 1), filename: "place_#{k + 1}.jpg")
  end

  users << u
end

puts "==> Creating random clients…"
client_count = 15
(1..client_count).each do |i|
  city, addr = pick_city_address
  u = User.new(
    email: "client#{i}@petcare.test",
    password: "123456",
    name: ["Marcos", "Bianca", "Rafael", "Camila", "Nina", "Paulo", "Rosa", "Tiago", "Ursula", "Vitor", "Wesley", "Yara"].sample + " #{%w[Almeida Castro Freitas Cardoso Moreira Barros].sample}",
    address: addr,
    city: city,
    cpf: cpf_from_seq(1000 + i),
    telephone: rand_phone_br,
    sitter: false,
    client: true
  )
  attach_from_url(u, :photo, avatar_urls_for(u).first)
  u.save!
  users << u
end

sitters  = users.select(&:sitter)
clients  = users.select(&:client) - sitters
clients << u2 unless clients.include?(u2)
clients.shuffle!

puts "==> Generating availabilities (next 30 days)…"
today = Date.current
range = (today..(today + 30))

total_avail = 0
sitters.each do |sitter|
  available_days = range.to_a.sample(rand(10..16)).sort
  available_days.each do |d|
    sitter.availabilities.create!(date: d)
    total_avail += 1
  end
end
puts "…created #{total_avail} availabilities."

puts "==> Creating bookings…"
all_unbooked = Availability.left_outer_joins(:booking).where(bookings: { id: nil }).to_a

# Multi-day bookings (group_token)
group_sets = 3
group_sets.times do
  sitter = sitters.sample
  days = sitter.availabilities.where(date: today..(today + 20)).pluck(:date).uniq.sort
  next if days.size < 3
  start_idx = rand(0..(days.size - 3))
  chosen = days[start_idx, 3]
  token = SecureRandom.hex(8)
  client = clients.sample

  chosen.each do |d|
    av = sitter.availabilities.find_by(date: d)
    next unless av && av.booking.nil?
    Booking.create!(
      availability: av,
      user: client,
      pet_name: ["Lua", "Thor", "Maya", "Rex", "Mel", "Bob"].sample,
      animal_type: ANIMAL_TYPES.sample,
      pet_size: PET_SIZES_PT.values.sample,
      pet_birth_year: rand(2012..2023),
      group_token: token
    )
    all_unbooked.delete(av)
  end
end

# Single-day bookings
single_count = 25
single_count.times do
  av = all_unbooked.sample
  break unless av
  client = clients.sample
  Booking.create!(
    availability: av,
    user: client,
    pet_name: ["Bento", "Luna", "Nina", "Toby", "Zeca", "Fiona"].sample,
    animal_type: ANIMAL_TYPES.sample,
    pet_size: PET_SIZES_PT.values.sample,
    pet_birth_year: rand(2010..2023)
  )
  all_unbooked.delete(av)
end

puts "==> Done!"
puts "Users: #{User.count} (Sitters: #{User.where(sitter: true).count}, Clients: #{User.where(client: true).count})"
puts "Availabilities: #{Availability.count}, Bookings: #{Booking.count}"
puts "Test logins:"
puts "  Sitter  -> email: sitter@petcare.test  / password: 123456"
puts "  Client  -> email: client@petcare.test  / password: 123456"
