# Usuarios
User.find_or_create_by!(email: "admin@mail.com") do |u|
  u.password = "admin123"
  u.password_confirmation = "admin123"
  u.role = :admin
  u.first_name = "Admin"
  u.last_name = "Sistema"
  u.joined_at = Time.current
end

User.find_or_create_by!(email: "cliente@mail.com") do |u|
  u.password = "cliente123"
  u.password_confirmation = "cliente123"
  u.role = :client
  u.first_name = "Cliente"
  u.last_name = "Prueba"
end

# Tipos de cancha (según el TP: Fútbol 5, 7, 11)
futbol5 = CourtType.find_or_create_by!(name: "Fútbol 5") do |ct|
  ct.surface              = :synthetic
  ct.capacity             = 10
  ct.max_duration_minutes = 60
  ct.price_per_hour       = 8000
end

futbol7 = CourtType.find_or_create_by!(name: "Fútbol 7") do |ct|
  ct.surface              = :natural
  ct.capacity             = 14
  ct.max_duration_minutes = 90
  ct.price_per_hour       = 12000
end

futbol11 = CourtType.find_or_create_by!(name: "Fútbol 11") do |ct|
  ct.surface              = :natural
  ct.capacity             = 22
  ct.max_duration_minutes = 120
  ct.price_per_hour       = 18000
end

# Canchas de ejemplo
Court.find_or_create_by!(name: "Cancha 1") { |c| c.court_type = futbol5;  c.status = :active }
Court.find_or_create_by!(name: "Cancha 2") { |c| c.court_type = futbol5;  c.status = :active }
Court.find_or_create_by!(name: "Cancha 3") { |c| c.court_type = futbol7;  c.status = :active }
Court.find_or_create_by!(name: "Cancha 4") { |c| c.court_type = futbol11; c.status = :active }

puts "Seeds: #{User.count} usuarios, #{CourtType.count} tipos, #{Court.count} canchas"
