module Reportes
  class TiposCanchaPdf < BasePdf
    def initialize(court_types)
      super()
      @court_types = court_types
    end

    def render
      encabezado("Tipos de Cancha y Características", "#{@court_types.count} tipos registrados")
      detalle
      pie_de_pagina
      @document.render
    end

    private

    def detalle
      seccion_titulo "Características por tipo de cancha"

      data = @court_types.map do |ct|
        [
          ct.name,
          CourtType::SURFACE_LABELS[ct.surface] || ct.surface,
          ct.capacity.to_s,
          ct.duration_label,
          format_money(ct.price_per_hour) + "/h",
          ct.courts.count.to_s
        ]
      end

      render_table(data, ["Nombre", "Superficie", "Capacidad", "Duración máx.", "Precio/hora", "Canchas"],
                   col_widths: [100, 100, 65, 80, 75, 55])
    end
  end
end
