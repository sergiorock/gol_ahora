module CourtsHelper
  def court_surface_svg(court_type, css_class: "w-full h-full")
    surface = court_type&.surface
    config  = surface_config(surface)
    uid     = "ct#{court_type&.id || SecureRandom.hex(4)}"

    content_tag(:svg, xmlns: "http://www.w3.org/2000/svg",
                viewBox: "0 0 400 200",
                preserveAspectRatio: "xMidYMid slice",
                class: css_class) do
      concat surface_defs(surface, config, uid)
      concat surface_background(surface, config, uid)
      concat court_lines(config[:line_color])
    end
  end

  private

  def surface_config(surface)
    case surface
    when "synthetic"
      # Verde vibrante limpio — sin patrón, la textura del sintético es uniforme desde arriba
      { bg_from: "#15803d", bg_to: "#16a34a", line_color: "rgba(255,255,255,0.65)", pattern: :none }
    when "natural"
      # Verde oscuro con franjas verticales alternadas — efecto corte de pasto vista aérea
      { bg_from: "#14532d", bg_to: "#15803d", line_color: "rgba(255,255,255,0.55)", pattern: :mow_stripes }
    when "parquet"
      # Ámbar con tablones horizontales bien definidos
      { bg_from: "#7c2d12", bg_to: "#9a3412", line_color: "rgba(255,255,255,0.55)", pattern: :planks }
    when "cement"
      # Azul sintético de polideportivo — color característico, liso sin textura
      { bg_from: "#1d4ed8", bg_to: "#2563eb", line_color: "rgba(255,255,255,0.7)", pattern: :none }
    else
      { bg_from: "#052e16", bg_to: "#0f3d1f", line_color: "rgba(255,255,255,0.4)", pattern: :none }
    end
  end

  def surface_defs(surface, config, uid)
    content_tag(:defs) do
      grad = content_tag(:linearGradient, id: "grad-#{uid}", x1: "0%", y1: "0%", x2: "0%", y2: "100%") do
        concat tag(:stop, offset: "0%",   style: "stop-color:#{config[:bg_from]};stop-opacity:1")
        concat tag(:stop, offset: "100%", style: "stop-color:#{config[:bg_to]};stop-opacity:1")
      end

      pattern = case config[:pattern]
      when :mow_stripes
        # Franjas verticales alternadas — banda clara cada 20px (vista aérea de pasto cortado)
        content_tag(:pattern, id: "pat-#{uid}", width: "20", height: "400",
                    patternUnits: "userSpaceOnUse") do
          tag(:rect, x: "0", y: "0", width: "10", height: "400",
              fill: "rgba(255,255,255,0.07)")
        end
      when :planks
        # Tablones horizontales: línea oscura de separación + borde luminoso superior
        content_tag(:pattern, id: "pat-#{uid}", width: "400", height: "18",
                    patternUnits: "userSpaceOnUse") do
          safe_join([
            tag(:rect, x: "0", y: "0", width: "400", height: "18", fill: "rgba(0,0,0,0)"),
            tag(:line, x1: "0", y1: "17.5", x2: "400", y2: "17.5",
                stroke: "rgba(0,0,0,0.3)", "stroke-width": "1.5"),
            tag(:line, x1: "0", y1: "0.5",  x2: "400", y2: "0.5",
                stroke: "rgba(255,255,255,0.08)", "stroke-width": "0.8")
          ])
        end
      end

      safe_join([grad, pattern].compact)
    end
  end

  def surface_background(surface, config, uid)
    rects = []
    rects << tag(:rect, x: "0", y: "0", width: "400", height: "200", fill: "url(#grad-#{uid})")
    rects << tag(:rect, x: "0", y: "0", width: "400", height: "200", fill: "url(#pat-#{uid})") if config[:pattern] != :none
    safe_join(rects)
  end

  def court_lines(color)
    lines = []

    # Borde del campo
    lines << tag(:rect, x: "30", y: "15", width: "340", height: "170",
                 fill: "none", stroke: color, "stroke-width": "1.5")
    # Línea del medio
    lines << tag(:line, x1: "200", y1: "15", x2: "200", y2: "185",
                 stroke: color, "stroke-width": "1.5")
    # Círculo central
    lines << tag(:circle, cx: "200", cy: "100", r: "28",
                 fill: "none", stroke: color, "stroke-width": "1.5")
    # Punto central
    lines << tag(:circle, cx: "200", cy: "100", r: "2.5", fill: color)

    # Área grande izquierda
    lines << tag(:rect, x: "30", y: "62", width: "48", height: "76",
                 fill: "none", stroke: color, "stroke-width": "1.5")
    # Área grande derecha
    lines << tag(:rect, x: "322", y: "62", width: "48", height: "76",
                 fill: "none", stroke: color, "stroke-width": "1.5")
    # Área chica izquierda
    lines << tag(:rect, x: "30", y: "82", width: "16", height: "36",
                 fill: "none", stroke: color, "stroke-width": "1.5")
    # Área chica derecha
    lines << tag(:rect, x: "354", y: "82", width: "16", height: "36",
                 fill: "none", stroke: color, "stroke-width": "1.5")

    # Punto del penal izquierdo
    lines << tag(:circle, cx: "62", cy: "100", r: "2.5", fill: color)
    # Punto del penal derecho
    lines << tag(:circle, cx: "338", cy: "100", r: "2.5", fill: color)

    # Medialuna izquierda
    lines << tag(:path, d: "M 78 77 A 28 28 0 0 1 78 123",
                 fill: "none", stroke: color, "stroke-width": "1.5")
    # Medialuna derecha
    lines << tag(:path, d: "M 322 77 A 28 28 0 0 0 322 123",
                 fill: "none", stroke: color, "stroke-width": "1.5")

    # Arcos de esquina
    lines << tag(:path, d: "M 30 21  A 6 6 0 0 0 36 15",  fill: "none", stroke: color, "stroke-width": "1.5")
    lines << tag(:path, d: "M 364 15 A 6 6 0 0 0 370 21", fill: "none", stroke: color, "stroke-width": "1.5")
    lines << tag(:path, d: "M 30 179 A 6 6 0 0 1 36 185", fill: "none", stroke: color, "stroke-width": "1.5")
    lines << tag(:path, d: "M 364 185 A 6 6 0 0 1 370 179", fill: "none", stroke: color, "stroke-width": "1.5")

    safe_join(lines)
  end
end
