module Reportes
  class ReservasPdf < BasePdf
    STATUS_LABELS = {
      "pending"     => "Pendiente",
      "confirmed"   => "Confirmada",
      "in_progress" => "En curso",
      "finished"    => "Finalizada",
      "cancelled"   => "Cancelada"
    }.freeze

    def initialize(reservations, filtros = nil)
      super()
      @reservations = reservations
      @filtros = filtros
    end

    def render
      encabezado("Reporte de Reservas", "#{@reservations.count} registros", @filtros)
      resumen
      detalle
      pie_de_pagina
      @document.render
    end

    private

    def resumen
      total_monto = @reservations.sum(:total_amount)
      confirmadas = @reservations.select { |r| r.status == "confirmed" || r.status == "finished" || r.status == "in_progress" }.count
      canceladas  = @reservations.select { |r| r.status == "cancelled" }.count

      seccion_titulo "Resumen"
      w = bounds.width
      table([
        ["Total reservas", @reservations.count.to_s, "Confirmadas/En curso/Finalizadas", confirmadas.to_s],
        ["Monto total", format_money(total_monto), "Canceladas", canceladas.to_s]
      ], width: w,
         cell_style: { size: 9, padding: [4, 8], border_color: BORDE, border_width: 0.5 }) do
        column(0).font_style = :bold
        column(0).text_color = GRIS
        column(2).font_style = :bold
        column(2).text_color = GRIS
        column(0).width = 130
        column(1).width = w / 2 - 130
        column(2).width = 180
      end
      move_down 14
    end

    def detalle
      seccion_titulo "Detalle de reservas"
      data = @reservations.map do |r|
        [
          I18n.l(r.starts_at, format: "%-d/%m/%Y"),
          "#{r.starts_at.strftime('%H:%M')} – #{r.ends_at.strftime('%H:%M')}",
          r.court.name,
          r.user.full_name,
          STATUS_LABELS[r.status] || r.status,
          format_money(r.total_amount)
        ]
      end

      render_table(data, ["Fecha", "Horario", "Cancha", "Cliente", "Estado", "Monto"],
                   col_widths: [62, 72, 80, 110, 70, 55])
    end
  end
end
