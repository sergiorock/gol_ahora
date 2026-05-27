class ReportePolicy < ApplicationPolicy
  def reservas?    = user&.admin?
  def cobros?      = user&.admin?
  def ocupacion?   = user&.admin?
  def tipos_cancha? = user&.admin?
  def asistencias_clases?         = user&.admin?
  def asistencias_entrenamientos? = user&.admin?
end
