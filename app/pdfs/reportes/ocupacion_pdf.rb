module Reportes
  class OcupacionPdf < BasePdf
    def initialize(datos, mes)
      super()
      @datos = datos
      @mes   = mes
    end

    def render
      mes_label = I18n.l(@mes, format: "%B %Y").capitalize
      encabezado("Reporte de Ocupación", mes_label)
      detalle
      pie_de_pagina
      @document.render
    end

    private

    def detalle
      seccion_titulo "Ocupación por cancha"

      total_reservas = @datos.sum { |d| d[:reservas] }
      total_horas    = @datos.sum { |d| d[:horas] }

      data = @datos.map do |d|
        pct = total_reservas > 0 ? (d[:reservas].to_f / total_reservas * 100).round(1) : 0
        [
          d[:court].name,
          d[:court].court_type.name,
          d[:reservas].to_s,
          "#{d[:horas]}h",
          "#{pct}%"
        ]
      end
      data << ["TOTAL", "", total_reservas.to_s, "#{total_horas.round(1)}h", "100%"]

      render_table(data, ["Cancha", "Tipo", "Reservas", "Horas", "% del total"],
                   col_widths: [130, 110, 70, 70, 70])

      move_down 8
      fill_color GRIS
      text "(*) Solo se cuentan reservas no canceladas del mes seleccionado.", size: 7, font: "Helvetica"
      fill_color OSCURO
    end
  end
end
