# Gol Ahora — Guía para Claude

## Proyecto
Sistema de gestión para el complejo deportivo "El Buen Deporte".
Trabajo Práctico de Ingeniería de Software I — UNAJ, Comisión 1.

## Stack
- Ruby on Rails 8.1 + Ruby 3.3
- PostgreSQL 16 (Docker)
- Devise (autenticación) + Pundit (autorización por rol)
- Bootstrap 5 + Tabler (UI admin) / Bootstrap 5 propio (UI cliente)
- Docker Compose
- Prawn + prawn-table (generación de PDFs)
- AASM (máquina de estados para Reserva)
- simple_form (formularios)

## Reglas de git
- Commits en español, lenguaje natural, sin prefijo de tipo
- No usar "feat:", "fix:", "chore:" ni ningún prefijo
- Máximo 100 caracteres por mensaje
- Ejemplos correctos:
  - "Agrega modelo de reservas con estados AASM"
  - "Corrige validación de seña al confirmar reserva"
  - "Agrega vistas de gestión de canchas"
- Ejemplos incorrectos:
  - "feat: add reservation model"
  - "Fix bug in reservation"

## Reglas de código
- Sin Turbo ni Stimulus; JS vanilla solo cuando sea estrictamente necesario
- Español para: commits, comentarios, nombres de dominio (ej: reserva, cancha)
- Inglés para: métodos Rails estándar, columnas de DB genéricas
- No comentar lo que el código ya expresa; solo comentar el "por qué" cuando no es obvio

## Modelo User (basado en diagrama de clases del TP)
Herencia del diagrama: Persona → Usuario → Administrador
En Rails se unifica en un solo modelo User con role enum.

Campos:
- email, encrypted_password (Devise)
- role: enum (admin: 0, cliente: 1)
- nombres, apellido, dni, edad (integer)
- telefono, domicilio, codigo_postal, pais, localidad
- fecha_ingreso: datetime (solo admin)

Relaciones (has_many):
- reservas, asistencias, inscripciones, equipos

PersonalDeportivo (Profesor/Entrenador del diagrama):
- modelo separado, no es usuario del sistema web
- tipo: enum (profesor, entrenador)
- campos propios + certificacion_deportiva

## Arquitectura
- Namespace Admin:: para todo el backoffice (controllers, views, policies)
- Controllers del cliente en nivel raíz
- Dos layouts: admin.html.erb (Tabler) y application.html.erb (Bootstrap 5 propio)
- Pundit aplicado en cada controller con authorize explícito
- Roles: enum en User — admin y cliente

## Docker
- Todos los comandos Rails van con bundle exec dentro del container:
  docker compose exec web bundle exec rails ...
- Para levantar por primera vez (o después de cambiar Gemfile):
  docker compose build && docker compose up
- Para levantar normalmente (DB y migraciones se corren solas):
  docker compose up
- Linux: si el USER_ID no es 1000, crear .env con:
  USER_ID=<id -u>
  GROUP_ID=<id -g>
  y hacer docker compose build antes del primer up
- Mac / Windows: no hace falta nada extra

## Módulos — orden de desarrollo
1. Auth (Devise, modelo User con rol, layouts base)
2. Canchas (TipoCancha → Cancha → BloqueoCancha → disponibilidad)
3. Reservas (AASM, pago simulado con tarjeta fake, PDF recibo)
4. Financiero (Cobros, Descuentos, Recibos)
5. Ligas y Torneos (Liga, Torneo, Inscripcion, Partido)
6. Academia (PersonalDeportivo, Clase, Entrenamiento, Asistencia)
7. Reportes PDF
8. Polish UI y QA
