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

puts "Seeds cargados: #{User.count} usuarios"
