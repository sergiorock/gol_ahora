module Reportes
  class CobrosPdf < BasePdf
    TIPO_LABELS = {
      "rental"     => "Alquiler",
      "enrollment" => "Inscripción",
      "class_fee"  => "Clase",
      "other"      => "Otro"
    }.freeze

    METHOD_LABELS = {
      "cash"     => "Efectivo",
      "transfer" => "Transferencia",
      "card"     => "Tarjeta"
    }.freeze

    def initialize(charges, total, filtros = nil)
      super()
      @charges = charges
      @total   = total
      @filtros = filtros
    end

    def render
      encabezado("Reporte de Cobros", "#{@charges.count} registros", @filtros)
      resumen
      detalle
      pie_de_pagina
      @document.render
    end

    private

    def resumen
      seccion_titulo "Resumen"
      por_tipo = @charges.group_by(&:charge_type).map do |tipo, cobros|
        [TIPO_LABELS[tipo] || tipo, cobros.count.to_s, format_money(cobros.sum(&:amount))]
      end
      por_tipo << ["TOTAL", @charges.count.to_s, format_money(@total)]

      table(por_tipo, width: 320,
            cell_style: { size: 9, padding: [4, 8], border_color: BORDE, border_width: 0.5 }) do
        column(0).font_style = :bold
        column(0).text_color = GRIS
        column(0).width = 160
        column(2).align = :right
        row(row_length - 1).font_style = :bold
        row(row_length - 1).background_color = "f0fdf4"
      end
      move_down 14
    end

    def detalle
      seccion_titulo "Detalle de cobros"
      data = @charges.map do |c|
        [
          I18n.l(c.date, format: "%-d/%m/%Y"),
          c.concept.truncate(35),
          TIPO_LABELS[c.charge_type] || c.charge_type,
          METHOD_LABELS[c.payment_method] || c.payment_method,
          c.user.full_name,
          format_money(c.amount)
        ]
      end

      render_table(data, ["Fecha", "Concepto", "Tipo", "Método", "Cliente", "Monto"],
                   col_widths: [55, 130, 65, 75, 100, 55])
    end
  end
end
