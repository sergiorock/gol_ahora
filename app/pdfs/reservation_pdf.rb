class ReservationPdf
  include Prawn::View

  VERDE  = "16a34a"
  OSCURO = "1a1a2e"
  GRIS   = "6b7280"
  BLANCO = "ffffff"
  BORDE  = "e5e7eb"

  STATUS_LABELS = {
    "pending"     => "Pendiente",
    "confirmed"   => "Confirmada",
    "in_progress" => "En curso",
    "finished"    => "Finalizada",
    "cancelled"   => "Cancelada"
  }.freeze

  SURFACE_LABELS = CourtType::SURFACE_LABELS

  def initialize(reservation)
    @r = reservation
    @document = Prawn::Document.new(page_size: "A4", margin: [40, 50, 40, 50])
  end

  def render
    encabezado
    datos_reserva
    resumen_financiero
    pie_de_pagina
    @document.render
  end

  private

  def encabezado
    bounding_box([0, cursor], width: bounds.width, height: 70) do
      fill_color VERDE
      fill_rectangle [0, 70], bounds.width, 70
      fill_color BLANCO
      text_box "GOL AHORA",     at: [16, 52], size: 22, style: :bold, font: "Helvetica"
      text_box "El Buen Deporte", at: [16, 28], size: 10, font: "Helvetica"
      text_box "Comprobante de reserva", at: [0, 52], width: bounds.width - 16, align: :right, size: 10, font: "Helvetica"
      text_box "Reserva ##{@r.id}", at: [0, 36], width: bounds.width - 16, align: :right, size: 10, font: "Helvetica"
    end
    move_down 80
    fill_color OSCURO
  end

  def datos_reserva
    seccion_titulo "Datos de la reserva"

    fila "Cliente",      @r.user.full_name
    fila "Email",        @r.user.email
    fila "Cancha",       @r.court.name
    fila "Tipo",         "#{@r.court.court_type.name} · #{SURFACE_LABELS[@r.court.court_type.surface]}"
    fila "Fecha",        I18n.l(@r.starts_at, format: "%-d de %B de %Y")
    fila "Horario",      "#{@r.starts_at.strftime('%H:%M')} – #{@r.ends_at.strftime('%H:%M')} (#{@r.duration_minutes} min)"
    fila "Estado",       STATUS_LABELS[@r.status] || @r.status
    fila "Total turno",  "$#{format_num(@r.total_amount.to_i)}"
    move_down 16
  end

  def resumen_financiero
    seccion_titulo "Resumen financiero"

    is_walkin  = @r.deposit_amount.to_i == 0
    deposit_c  = @r.deposit_charge
    balance_c  = @r.balance_charge
    paid_total = deposit_c&.amount.to_i + balance_c&.amount.to_i

    rows = []

    unless is_walkin
      if deposit_c
        rows << ["Seña (30%) — pago online", "Tarjeta ••••#{deposit_c&.amount}", "$#{format_num(deposit_c.amount.to_i)}", "Aprobado"]
      else
        rows << ["Seña (30%) — pago online", "—", "$#{format_num(@r.deposit_amount.to_i)}", "Pendiente"]
      end
    end

    if balance_c
      method_label = { "cash" => "Efectivo", "transfer" => "Transferencia", "card" => "Tarjeta" }[balance_c.payment_method] || balance_c.payment_method
      rows << [is_walkin ? "Pago total" : "Saldo (70%) — cobro presencial", method_label, "$#{format_num(balance_c.amount.to_i)}", "Cobrado"]
    else
      rows << [is_walkin ? "Pago total" : "Saldo (70%) — cobro presencial", "—", "$#{format_num(@r.total_amount.to_i - @r.deposit_amount.to_i)}", "Pendiente"]
    end

    rows << ["Total cobrado", "", "$#{format_num(paid_total)}", ""]

    table(rows, width: bounds.width,
          cell_style: { border_width: 0, padding: [5, 6], size: 9 },
          header: false) do
      column(0).font_style = :bold
      column(0).text_color = OSCURO
      column(2).align = :right
      column(3).align = :center
      rows_count = row_length
      row(rows_count - 1).font_style = :bold
      row(rows_count - 1).size       = 10
      row(rows_count - 1).background_color = "f9fafb"

      rows.each_with_index do |r, i|
        row(i).text_color = r[3] == "Pendiente" ? "d97706" : (r[3] == "Cobrado" || r[3] == "Aprobado" ? "16a34a" : OSCURO)
      end
    end
    move_down 16
  end

  def seccion_titulo(titulo)
    fill_color VERDE
    text titulo, size: 11, style: :bold
    stroke_color BORDE
    stroke_horizontal_rule
    fill_color OSCURO
    move_down 8
  end

  def fila(label, valor)
    table([[label, valor.to_s]], width: bounds.width,
          cell_style: { border_width: 0, padding: [3, 6] }) do
      column(0).font_style = :bold
      column(0).width      = 130
      column(0).text_color = GRIS
      column(0).size       = 9
      column(1).size       = 9
      column(1).text_color = OSCURO
    end
  end

  def pie_de_pagina
    bounding_box([0, 20], width: bounds.width) do
      stroke_color BORDE
      stroke_horizontal_rule
      move_down 6
      fill_color GRIS
      text "Gol Ahora — El Buen Deporte · Generado el #{Time.current.strftime('%d/%m/%Y a las %H:%M')}",
        size: 8, align: :center
    end
  end

  def format_num(n)
    n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
  end
end
