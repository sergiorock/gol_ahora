class ReceiptPdf
  include Prawn::View

  VERDE  = "16a34a"
  OSCURO = "1a1a2e"
  GRIS   = "6b7280"
  BLANCO = "ffffff"
  BORDE  = "e5e7eb"

  def initialize(receipt)
    @receipt = receipt
    @charge  = receipt.charge
    @document = Prawn::Document.new(page_size: "A4", margin: [40, 50, 40, 50])
  end

  def render
    encabezado
    datos_recibo
    pie_de_pagina
    @document.render
  end

  private

  def encabezado
    bounding_box([0, cursor], width: bounds.width, height: 70) do
      fill_color VERDE
      fill_rectangle [0, 70], bounds.width, 70
      fill_color BLANCO
      text_box "GOL AHORA",       at: [16, 52], size: 22, style: :bold, font: "Helvetica"
      text_box "El Buen Deporte", at: [16, 28], size: 10, font: "Helvetica"
      text_box "Recibo de pago",  at: [0, 52], width: bounds.width - 16, align: :right, size: 10, font: "Helvetica"
      text_box @receipt.receipt_number, at: [0, 36], width: bounds.width - 16, align: :right, size: 12, style: :bold, font: "Helvetica"
    end
    move_down 80
    fill_color OSCURO
  end

  def datos_recibo
    seccion_titulo "Datos del comprobante"
    fila "Número",       @receipt.receipt_number
    fila "Fecha",        I18n.l(@receipt.issued_at, format: "%-d de %B de %Y, %H:%M")
    fila "Cliente",      @charge.user.full_name
    fila "Email",        @charge.user.email
    move_down 12

    seccion_titulo "Detalle del cobro"
    fila "Concepto",     @receipt.concept
    fila "Tipo",         I18n.t("charge.types.#{@charge.charge_type}", default: @charge.charge_type)
    fila "Método pago",  I18n.t("charge.payment_methods.#{@charge.payment_method}", default: @charge.payment_method)
    fila "Fecha cobro",  I18n.l(@charge.date, format: :long)
    move_down 12

    fill_color VERDE
    fill_rectangle [0, cursor], bounds.width, 40
    fill_color BLANCO
    text_box "TOTAL", at: [16, cursor - 8], size: 12, style: :bold, font: "Helvetica"
    text_box "$#{format_num(@charge.amount.to_i)}", at: [0, cursor - 8],
      width: bounds.width - 16, align: :right, size: 16, style: :bold, font: "Helvetica"
    move_down 50
    fill_color OSCURO
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
