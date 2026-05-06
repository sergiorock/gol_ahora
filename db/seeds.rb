User.find_or_create_by!(email: "admin@mail.com") do |u|
  u.password = "admin123"
  u.password_confirmation = "admin123"
  u.role = :admin
  u.nombres = "Admin"
  u.apellido = "Sistema"
  u.fecha_ingreso = Time.current
end

User.find_or_create_by!(email: "cliente@mail.com") do |u|
  u.password = "cliente123"
  u.password_confirmation = "cliente123"
  u.role = :cliente
  u.nombres = "Cliente"
  u.apellido = "Prueba"
end

puts "Seeds cargados: #{User.count} usuarios"
