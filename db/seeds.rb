# ── Usuarios ────────────────────────────────────────────────────────────────
admin = User.find_or_initialize_by(email: "admin@mail.com")
admin.assign_attributes(
  password:              "admin123",
  password_confirmation: "admin123",
  role:                  :admin,
  first_name:            "Carlos",
  last_name:             "Rodríguez",
  dni:                   "25123456",
  birth_date:            Date.new(1985, 6, 15),
  phone:                 "1145678901",
  address:               "Av. Mitre 1234",
  postal_code:           "1870",
  city:                  "Florencio Varela",
  country:               "AR",
  joined_at:             admin.joined_at || Time.current
)
admin.save!

cliente = User.find_or_initialize_by(email: "cliente@mail.com")
cliente.assign_attributes(
  password:              "cliente123",
  password_confirmation: "cliente123",
  role:                  :client,
  first_name:            "Martín",
  last_name:             "González",
  dni:                   "38456789",
  birth_date:            Date.new(1995, 3, 22),
  phone:                 "1167890123",
  address:               "Calle 9 de Julio 456",
  postal_code:           "1888",
  city:                  "Quilmes",
  country:               "AR"
)
cliente.save!

# ── Tipos de cancha ──────────────────────────────────────────────────────────
# Una combinación por tamaño (5/7/11) × superficie (synthetic/natural/parquet/cement)

# Parquet y cemento solo para Fútbol 5 (superficies de piso interior/futsal)
COURT_TYPES = [
  { name: "Fútbol 5",  surface: :synthetic, capacity: 10, max_duration_minutes: 60,  price_per_hour: 8_000  },
  { name: "Fútbol 5",  surface: :natural,   capacity: 10, max_duration_minutes: 60,  price_per_hour: 10_000 },
  { name: "Fútbol 5",  surface: :parquet,   capacity: 10, max_duration_minutes: 60,  price_per_hour: 9_000  },
  { name: "Fútbol 5",  surface: :cement,    capacity: 10, max_duration_minutes: 60,  price_per_hour: 7_000  },
  { name: "Fútbol 7",  surface: :synthetic, capacity: 14, max_duration_minutes: 90,  price_per_hour: 11_000 },
  { name: "Fútbol 7",  surface: :natural,   capacity: 14, max_duration_minutes: 90,  price_per_hour: 12_000 },
  { name: "Fútbol 11", surface: :synthetic, capacity: 22, max_duration_minutes: 120, price_per_hour: 16_000 },
  { name: "Fútbol 11", surface: :natural,   capacity: 22, max_duration_minutes: 120, price_per_hour: 18_000 },
].freeze

COURT_TYPES.each do |attrs|
  CourtType.find_or_create_by!(name: attrs[:name], surface: attrs[:surface]) do |ct|
    ct.capacity             = attrs[:capacity]
    ct.max_duration_minutes = attrs[:max_duration_minutes]
    ct.price_per_hour       = attrs[:price_per_hour]
  end
end

# ── Canchas ──────────────────────────────────────────────────────────────────
# Nombres cortos estilo complejo real. El tipo y superficie se ven en la card.
courts_data = [
  { name: "Cancha 1", court_type: CourtType.find_by(name: "Fútbol 5",  surface: "synthetic") },
  { name: "Cancha 2", court_type: CourtType.find_by(name: "Fútbol 5",  surface: "natural")   },
  { name: "Cancha 3", court_type: CourtType.find_by(name: "Fútbol 5",  surface: "parquet")   },
  { name: "Cancha 4", court_type: CourtType.find_by(name: "Fútbol 5",  surface: "cement")    },
  { name: "Cancha 5", court_type: CourtType.find_by(name: "Fútbol 7",  surface: "synthetic") },
  { name: "Cancha 6", court_type: CourtType.find_by(name: "Fútbol 7",  surface: "natural")   },
  { name: "Cancha 7", court_type: CourtType.find_by(name: "Fútbol 11", surface: "synthetic") },
  { name: "Cancha 8", court_type: CourtType.find_by(name: "Fútbol 11", surface: "natural")   },
]

courts_data.each do |data|
  next unless data[:court_type]
  Court.find_or_create_by!(name: data[:name]) do |c|
    c.court_type = data[:court_type]
    c.status     = :active
  end
end

puts "Seeds: #{User.count} usuarios, #{CourtType.count} tipos de cancha, #{Court.count} canchas"
