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
      { bg_from: "#166534", bg_to: "#15803d", line_color: "rgba(255,255,255,0.6)", pattern: :crosshatch }
    when "natural"
      { bg_from: "#14532d", bg_to: "#166534", line_color: "rgba(255,255,255,0.5)", pattern: :stripes }
    when "parquet"
      { bg_from: "#78350f", bg_to: "#92400e", line_color: "rgba(255,255,255,0.5)", pattern: :planks }
    when "cement"
      { bg_from: "#1f2937", bg_to: "#374151", line_color: "rgba(255,255,255,0.5)", pattern: :none }
    else
      { bg_from: "#052e16", bg_to: "#0f3d1f", line_color: "rgba(255,255,255,0.4)", pattern: :none }
    end
  end

  def surface_defs(surface, config, uid)
    content_tag(:defs) do
      grad = content_tag(:linearGradient, id: "grad-#{uid}", x1: "0%", y1: "0%", x2: "100%", y2: "100%") do
        concat tag(:stop, offset: "0%",   style: "stop-color:#{config[:bg_from]};stop-opacity:1")
        concat tag(:stop, offset: "100%", style: "stop-color:#{config[:bg_to]};stop-opacity:1")
      end

      pattern = case config[:pattern]
      when :crosshatch
        content_tag(:pattern, id: "pat-#{uid}", width: "12", height: "12",
                    patternUnits: "userSpaceOnUse", patternTransform: "rotate(45)") do
          concat tag(:line, x1: "0", y1: "0", x2: "0", y2: "12",
                     stroke: "rgba(0,0,0,0.15)", "stroke-width": "4")
          concat tag(:line, x1: "0", y1: "0", x2: "12", y2: "0",
                     stroke: "rgba(0,0,0,0.15)", "stroke-width": "4")
        end
      when :stripes
        content_tag(:pattern, id: "pat-#{uid}", width: "30", height: "30",
                    patternUnits: "userSpaceOnUse") do
          tag(:rect, x: "0", y: "0", width: "30", height: "15",
              fill: "rgba(0,0,0,0.12)")
        end
      when :planks
        content_tag(:pattern, id: "pat-#{uid}", width: "400", height: "16",
                    patternUnits: "userSpaceOnUse") do
          concat tag(:rect, x: "0", y: "0", width: "400", height: "16", fill: "rgba(0,0,0,0)")
          concat tag(:line, x1: "0", y1: "15.5", x2: "400", y2: "15.5",
                     stroke: "rgba(0,0,0,0.25)", "stroke-width": "1")
          concat tag(:line, x1: "0", y1: "0.5", x2: "400", y2: "0.5",
                     stroke: "rgba(255,255,255,0.06)", "stroke-width": "0.5")
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
    # Líneas reglamentarias escaladas al viewBox 400x200
    # Campo: x=30..370 (340px) × y=15..185 (170px)
    lines = []
    s = color

    # Borde
    lines << tag(:rect, x: "30", y: "15", width: "340", height: "170",
                 fill: "none", stroke: s, "stroke-width": "1.5")
    # Línea del medio
    lines << tag(:line, x1: "200", y1: "15", x2: "200", y2: "185",
                 stroke: s, "stroke-width": "1.5")
    # Círculo central
    lines << tag(:circle, cx: "200", cy: "100", r: "28",
                 fill: "none", stroke: s, "stroke-width": "1.5")
    # Punto central
    lines << tag(:circle, cx: "200", cy: "100", r: "2", fill: s)

    # Área grande izquierda
    lines << tag(:rect, x: "30", y: "62", width: "48", height: "76",
                 fill: "none", stroke: s, "stroke-width": "1.5")
    # Área grande derecha
    lines << tag(:rect, x: "322", y: "62", width: "48", height: "76",
                 fill: "none", stroke: s, "stroke-width": "1.5")
    # Área chica izquierda
    lines << tag(:rect, x: "30", y: "82", width: "16", height: "36",
                 fill: "none", stroke: s, "stroke-width": "1.5")
    # Área chica derecha
    lines << tag(:rect, x: "354", y: "82", width: "16", height: "36",
                 fill: "none", stroke: s, "stroke-width": "1.5")

    # Punto del penal izquierdo
    lines << tag(:circle, cx: "62", cy: "100", r: "2", fill: s)
    # Punto del penal derecho
    lines << tag(:circle, cx: "338", cy: "100", r: "2", fill: s)

    # Medialuna izquierda (fuera del área, hacia el centro)
    # Centro en (62,100), r=28. Intersección con x=78: y=100±sqrt(28²-16²)=100±23
    lines << tag(:path, d: "M 78 77 A 28 28 0 0 1 78 123",
                 fill: "none", stroke: s, "stroke-width": "1.5")
    # Medialuna derecha
    lines << tag(:path, d: "M 322 77 A 28 28 0 0 0 322 123",
                 fill: "none", stroke: s, "stroke-width": "1.5")

    # Arcos de esquina
    lines << tag(:path, d: "M 30 21 A 6 6 0 0 0 36 15", fill: "none", stroke: s, "stroke-width": "1.5")
    lines << tag(:path, d: "M 364 15 A 6 6 0 0 0 370 21", fill: "none", stroke: s, "stroke-width": "1.5")
    lines << tag(:path, d: "M 30 179 A 6 6 0 0 1 36 185", fill: "none", stroke: s, "stroke-width": "1.5")
    lines << tag(:path, d: "M 364 185 A 6 6 0 0 1 370 179", fill: "none", stroke: s, "stroke-width": "1.5")

    safe_join(lines)
  end
end
