class UserPdf
  include Prawn::View

  VERDE   = "16a34a"
  OSCURO  = "1a1a2e"
  GRIS    = "6b7280"
  BLANCO  = "ffffff"
  BORDE   = "e5e7eb"

  def initialize(user)
    @user = user
    @document = Prawn::Document.new(
      page_size: "A4",
      margin: [40, 50, 40, 50]
    )
  end

  def render
    encabezado
    datos_acceso
    datos_personales
    pie_de_pagina
    @document.render
  end

  private

  def encabezado
    bounding_box([0, cursor], width: bounds.width, height: 70) do
      fill_color VERDE
      fill_rectangle [0, 70], bounds.width, 70

      fill_color BLANCO
      text_box "GOL AHORA", at: [16, 52],
        size: 22, style: :bold, font: "Helvetica"
      text_box "El Buen Deporte", at: [16, 28],
        size: 10, font: "Helvetica"

      fill_color BLANCO
      text_box "Ficha de Usuario", at: [0, 52],
        width: bounds.width - 16, align: :right, size: 10, font: "Helvetica"
      text_box Time.current.strftime("%d/%m/%Y"), at: [0, 36],
        width: bounds.width - 16, align: :right, size: 10, font: "Helvetica"
    end

    move_down 80
    fill_color OSCURO

    text @user.full_name, size: 18, style: :bold
    fill_color GRIS
    text @user.email, size: 10
    fill_color OSCURO
    move_down 6

    fill_color VERDE
    fill_rectangle [0, cursor], bounds.width, 2
    fill_color OSCURO
    move_down 16
  end

  def datos_acceso
    seccion_titulo "Datos de acceso"

    fila "Rol",   @user.admin? ? "Administrador" : "Cliente"
    fila "Email", @user.email
    if @user.admin? && @user.joined_at
      fila "Fecha de ingreso", @user.joined_at.strftime("%d/%m/%Y")
    end
    move_down 12
  end

  def datos_personales
    seccion_titulo "Datos personales"

    fila "Nombres",       @user.first_name
    fila "Apellido",      @user.last_name
    fila "DNI",           @user.dni.presence || "—"
    fila "Fecha nacimiento", @user.birth_date ? "#{I18n.l(@user.birth_date, format: :long)} (#{@user.age} años)" : "—"
    fila "Teléfono",      @user.phone.presence || "—"
    fila "Domicilio",     @user.address.presence || "—"
    fila "Código postal", @user.postal_code.presence || "—"
    fila "Ciudad",        @user.city.presence || "—"
    fila "País",          @user.country.presence || "—"
    move_down 12
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
    table_data = [[label, valor.to_s]]

    table(table_data, width: bounds.width, cell_style: { border_width: 0, padding: [4, 6] }) do
      column(0).font_style = :bold
      column(0).width       = 130
      column(0).text_color  = GRIS
      column(0).size        = 9
      column(1).size        = 9
      column(1).text_color  = OSCURO
    end
  end

  def pie_de_pagina
    bounding_box([0, 20], width: bounds.width) do
      stroke_color BORDE
      stroke_horizontal_rule
      move_down 6
      fill_color GRIS
      text "Gol Ahora — El Buen Deporte · Documento generado el #{Time.current.strftime('%d/%m/%Y a las %H:%M')}",
        size: 8, align: :center
    end
  end
end
