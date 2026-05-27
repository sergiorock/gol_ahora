module Reportes
  class BasePdf
    include Prawn::View

    VERDE  = "16a34a"
    OSCURO = "111827"
    GRIS   = "6b7280"
    GRIS_L = "f3f4f6"
    BORDE  = "e5e7eb"
    BLANCO = "ffffff"

    def initialize
      @document = Prawn::Document.new(
        page_size: "A4",
        page_layout: :portrait,
        margin: [40, 45, 40, 45]
      )
    end

    private

    def encabezado(titulo, subtitulo = nil, filtros = nil)
      bounding_box([0, cursor], width: bounds.width, height: 64) do
        fill_color VERDE
        fill_rectangle [0, 64], bounds.width, 64
        fill_color BLANCO
        text_box "GOL AHORA",       at: [14, 46], size: 18, style: :bold,  font: "Helvetica"
        text_box "El Buen Deporte", at: [14, 26], size: 9,                  font: "Helvetica"
        text_box titulo,            at: [0, 46],  width: bounds.width - 14, align: :right, size: 13, style: :bold, font: "Helvetica"
        if subtitulo
          text_box subtitulo,       at: [0, 28],  width: bounds.width - 14, align: :right, size: 9,  font: "Helvetica"
        end
      end
      move_down 74
      fill_color OSCURO

      if filtros.present?
        fill_color "f0fdf4"
        fill_rounded_rectangle [0, cursor], bounds.width, 22, 4
        fill_color GRIS
        text_box "Filtros aplicados: #{filtros}", at: [8, cursor - 6], width: bounds.width - 16, size: 8, font: "Helvetica"
        move_down 28
        fill_color OSCURO
      end
    end

    def seccion_titulo(titulo)
      fill_color VERDE
      text titulo, size: 10, style: :bold, font: "Helvetica"
      stroke_color BORDE
      stroke_horizontal_rule
      fill_color OSCURO
      move_down 6
    end

    def pie_de_pagina
      bounding_box([0, 20], width: bounds.width) do
        stroke_color BORDE
        stroke_horizontal_rule
        move_down 5
        fill_color GRIS
        generado = "Generado el #{Time.current.strftime('%d/%m/%Y a las %H:%M')}"
        text "Gol Ahora — El Buen Deporte  ·  #{generado}", size: 7, align: :center, font: "Helvetica"
      end
    end

    def format_num(n)
      n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse
    end

    def format_money(n)
      "$#{format_num(n.to_i)}"
    end

    def th_style
      { background_color: VERDE, text_color: BLANCO, font_style: :bold, size: 8, padding: [5, 6], border_width: 0 }
    end

    def td_style
      { size: 8, padding: [4, 6], border_width: 0, border_color: BORDE }
    end

    def render_table(data, headers, col_widths: nil)
      return if data.empty?

      header_row = headers.map { |h| { content: h, **th_style } }
      rows = [header_row] + data

      table_width = col_widths ? col_widths.sum : bounds.width
      opts = {
        width: table_width,
        header: true,
        cell_style: td_style,
        row_colors: [BLANCO, GRIS_L]
      }
      opts[:column_widths] = col_widths if col_widths

      table(rows, **opts) do
        row(0).borders = []
      end
    end
  end
end
