module Reportes
  class AsistenciasClasesPdf < BasePdf
    def initialize(asistencias, presentes, filtros = nil)
      super()
      @asistencias = asistencias
      @presentes   = presentes
      @filtros     = filtros
    end

    def render
      encabezado("Reporte de Asistencia — Clases", "#{@asistencias.count} inscripciones", @filtros)
      resumen
      detalle
      pie_de_pagina
      @document.render
    end

    private

    def resumen
      seccion_titulo "Resumen"
      ausentes = @asistencias.count - @presentes
      pct = @asistencias.count > 0 ? (@presentes.to_f / @asistencias.count * 100).round(1) : 0
      table([
        ["Total inscripciones", @asistencias.count.to_s, "Presentes", "#{@presentes} (#{pct}%)"],
        ["", "", "Ausentes / Sin confirmar", ausentes.to_s]
      ], width: bounds.width,
         cell_style: { size: 9, padding: [4, 8], border_color: BORDE, border_width: 0.5 }) do
        column(0).font_style = :bold
        column(0).text_color = GRIS
        column(2).font_style = :bold
        column(2).text_color = GRIS
        column(0).width = 130
        column(2).width = 180
      end
      move_down 14
    end

    def detalle
      seccion_titulo "Detalle de asistencias"
      data = @asistencias.map do |a|
        clase = a.asistible
        [
          I18n.l(a.attended_on, format: "%-d/%m/%Y"),
          clase&.nombre || "—",
          clase&.personal_deportivo&.full_name || "—",
          a.user.full_name,
          a.present ? "Presente" : "Pendiente"
        ]
      end

      render_table(data, ["Fecha", "Clase", "Profesor", "Alumno", "Asistencia"],
                   col_widths: [60, 120, 110, 110, 65])
    end
  end
end
