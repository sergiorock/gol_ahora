# Plan de desarrollo — Gol Ahora

## Etapa 0 — Base técnica
- [x] Agregar gems (devise, pundit, aasm, simple_form, prawn, prawn-table, annotate)
- [x] Rebuild Docker con nuevas gems
- [ ] Instalar Devise (`rails generate devise:install`)
- [ ] Generar modelo User con Devise + campos de Persona + role enum
- [ ] Instalar Pundit (`rails generate pundit:install`)
- [ ] Instalar simple_form con Bootstrap
- [ ] Layout `admin.html.erb` con Tabler (CDN)
- [ ] Layout `application.html.erb` con Bootstrap 5 (CDN)
- [ ] Namespace `Admin::` en routes
- [ ] `Admin::BaseController` con Pundit
- [ ] `ApplicationController` con Pundit
- [ ] `HomeController#index` (landing cliente)
- [ ] `Admin::DashboardController#index`
- [ ] `Admin::UsuariosController` (CRUD completo — RF-001 a RF-005)
- [ ] Seed con usuario admin inicial

## Etapa 1 — Canchas (RF-006 a RF-018)
- [ ] Modelo `TipoCancha` (nombre, superficie, capacidad, duracion_maxima, precio_hora)
- [ ] Modelo `Cancha` (nombre, tipo_cancha, descripcion, estado enum)
- [ ] Modelo `BloqueoCancha` (cancha, fecha_inicio, fecha_fin, motivo)
- [ ] `Admin::TipoCanchasController` CRUD
- [ ] `Admin::CanchasController` CRUD
- [ ] `Admin::BloqueosController` CRUD
- [ ] `Admin::DisponibilidadesController` (vista semanal)
- [ ] `CanchasController` (vista cliente — index y show)
- [ ] Reporte de tipo de cancha PDF (RF-010)
- [ ] Reporte de disponibilidad PDF (RF-018)

## Etapa 2 — Reservas (RF-019 a RF-022)
- [ ] Modelo `Reserva` con AASM (estados: pendiente, confirmada, en_curso, finalizada, cancelada)
- [ ] Modelo `Pago` (reserva, monto, tipo, estado, ultimos_cuatro_digitos, nombre_titular, vencimiento)
- [ ] Validaciones: no doble reserva, duración máxima, anticipación 30 días, cancha no bloqueada
- [ ] `ReservasController` (cliente): new, create, show, index, pagar, confirmar_pago, cancelar
- [ ] `Admin::ReservasController` CRUD + cambio de estado manual
- [ ] Formulario de pago simulado (tarjeta fake)
- [ ] Reporte de reservas PDF (RF-022)

## Etapa 3 — Gestión financiera (RF-073 a RF-087)
- [ ] Modelo `Descuento` (nombre, tipo enum, valor, condicion, activo)
- [ ] Modelo `Cobro` (user, monto, concepto, tipo, fecha, descuento)
- [ ] Modelo `ReciboPago` (cobro, numero_recibo autogenerado, fecha_emision, concepto)
- [ ] `Admin::DescuentosController` CRUD
- [ ] `Admin::CobrosController` CRUD + imprimir + PDF
- [ ] `Admin::RecibosController` CRUD + PDF con Prawn
- [ ] Reporte de ingresos PDF

## Etapa 4 — Ligas, torneos y partidos (RF-023 a RF-032, RF-088 a RF-091)
- [ ] Modelo `Liga` (nombre, fechas, estado enum, reglamento)
- [ ] Modelo `Torneo` (nombre, formato enum, fechas, estado, reglamento)
- [ ] Modelo `Partido` (polymorphic a Liga/Torneo, equipos, goles, fecha, reglas)
- [ ] `Admin::LigasController` CRUD
- [ ] `Admin::TorneosController` CRUD + fixture
- [ ] `Admin::PartidosController` (registrar y modificar resultados)
- [ ] `LigasController` y `TorneosController` (vista cliente)

## Etapa 5 — Inscripciones (RF-033 a RF-042)
- [ ] Modelo `Inscripcion` (user, inscribible polymorphic a Liga/Torneo, estado enum)
- [ ] `Admin::InscripcionesController` CRUD
- [ ] `InscripcionesController` (cliente): index, inscribirse, cancelar

## Etapa 6 — Personal deportivo y academia (RF-043 a RF-072)
- [ ] Modelo `PersonalDeportivo` (nombre, apellido, tipo enum: profesor/entrenador, certificacion)
- [ ] Modelo `Clase` (nombre, horario, duracion, personal_deportivo, max_alumnos, tipo_cancha)
- [ ] Modelo `Entrenamiento` (nombre, horario, duracion, personal_deportivo, max_alumnos)
- [ ] Modelo `Asistencia` (user, asistible polymorphic a Clase/Entrenamiento, presente)
- [ ] `Admin::PersonalDeportivosController` CRUD
- [ ] `Admin::ClasesController` CRUD + asistencia + reporte PDF
- [ ] `Admin::EntrenamientosController` CRUD + asistencia + reporte PDF
- [ ] `ClasesController` y `EntrenamientosController` (vista cliente)

## Etapa 7 — Reportes PDF y polish UI
- [ ] Reporte de ocupación de canchas
- [ ] Reporte de asistencia a clases
- [ ] Reporte de asistencia a entrenamientos
- [ ] Dashboard admin con métricas (reservas hoy, ingresos del mes)
- [ ] Navbar cliente con menú de usuario
- [ ] Paginación en tablas largas
- [ ] Polish general y QA
