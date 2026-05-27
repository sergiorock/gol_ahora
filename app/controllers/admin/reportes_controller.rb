class Admin::ReportesController < Admin::BaseController
  before_action :authorize_reporte

  def reservas
    @courts = Court.order(:name)
    scope = Reservation.includes(:user, court: :court_type).order(starts_at: :desc)
    scope = scope.where(status: params[:status])     if params[:status].present?
    scope = scope.where(court_id: params[:court_id]) if params[:court_id].present?
    scope = scope.where("DATE(starts_at) >= ?", params[:desde].to_date) if params[:desde].present?
    scope = scope.where("DATE(starts_at) <= ?", params[:hasta].to_date) if params[:hasta].present?
    @reservations = scope

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Reportes::ReservasPdf.new(@reservations, filtros_label)
        send_data pdf.render, filename: "reporte-reservas.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def cobros
    @charge_types = Charge.charge_types.keys
    scope = Charge.includes(:user, :discount).order(date: :desc)
    scope = scope.where(charge_type: params[:charge_type]) if params[:charge_type].present?
    scope = scope.where("date >= ?", params[:desde].to_date) if params[:desde].present?
    scope = scope.where("date <= ?", params[:hasta].to_date) if params[:hasta].present?
    @charges = scope
    @total = @charges.sum(:amount)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Reportes::CobrosPdf.new(@charges, @total, filtros_label)
        send_data pdf.render, filename: "reporte-cobros.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def ocupacion
    @courts = Court.includes(:court_type).order(:name)
    mes = params[:mes].present? ? Date.parse("#{params[:mes]}-01") : Date.today.beginning_of_month
    @mes = mes
    @datos = @courts.map do |court|
      reservas = court.reservations.where(starts_at: mes.beginning_of_month..mes.end_of_month).where.not(status: :cancelled)
      horas = reservas.sum { |r| r.duration_minutes } / 60.0
      { court: court, reservas: reservas.count, horas: horas.round(1) }
    end

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Reportes::OcupacionPdf.new(@datos, @mes)
        send_data pdf.render, filename: "reporte-ocupacion-#{@mes.strftime('%Y-%m')}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def tipos_cancha
    @court_types = CourtType.includes(:courts).order(:name)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Reportes::TiposCanchaPdf.new(@court_types)
        send_data pdf.render, filename: "reporte-tipos-cancha.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def asistencias_clases
    @clases = Clase.order(:nombre)
    scope = Asistencia.includes(:user, asistible: :personal_deportivo)
                      .where(asistible_type: "Clase")
                      .order(attended_on: :desc)
    scope = scope.where(asistible_id: params[:clase_id]) if params[:clase_id].present?
    scope = scope.where("attended_on >= ?", params[:desde].to_date) if params[:desde].present?
    scope = scope.where("attended_on <= ?", params[:hasta].to_date) if params[:hasta].present?
    @asistencias = scope
    @presentes = @asistencias.where(present: true).count

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Reportes::AsistenciasClasesPdf.new(@asistencias, @presentes, filtros_label)
        send_data pdf.render, filename: "reporte-asistencias-clases.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def asistencias_entrenamientos
    @entrenamientos = Entrenamiento.order(:nombre)
    scope = Asistencia.includes(:user, asistible: :personal_deportivo)
                      .where(asistible_type: "Entrenamiento")
                      .order(attended_on: :desc)
    scope = scope.where(asistible_id: params[:entrenamiento_id]) if params[:entrenamiento_id].present?
    scope = scope.where("attended_on >= ?", params[:desde].to_date) if params[:desde].present?
    scope = scope.where("attended_on <= ?", params[:hasta].to_date) if params[:hasta].present?
    @asistencias = scope
    @presentes = @asistencias.where(present: true).count

    respond_to do |format|
      format.html
      format.pdf do
        pdf = Reportes::AsistenciasEntrenamientosPdf.new(@asistencias, @presentes, filtros_label)
        send_data pdf.render, filename: "reporte-asistencias-entrenamientos.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  private

  def authorize_reporte
    authorize :reporte, :"#{action_name}?"
  end

  def filtros_label
    parts = []
    parts << "Desde: #{params[:desde]}" if params[:desde].present?
    parts << "Hasta: #{params[:hasta]}" if params[:hasta].present?
    parts.join("  ·  ")
  end
end
