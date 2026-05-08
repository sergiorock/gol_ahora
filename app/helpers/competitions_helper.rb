module CompetitionsHelper
  LEAGUE_STATUS_STYLES = {
    "open"        => { label: "Abierta",   css: "bg-success-lt text-success" },
    "in_progress" => { label: "En curso",  css: "bg-info-lt text-info" },
    "finished"    => { label: "Finalizada", css: "bg-secondary-lt text-secondary" }
  }.freeze

  TOURNAMENT_STATUS_STYLES = {
    "open"        => { label: "Abierto",   css: "bg-success-lt text-success" },
    "in_progress" => { label: "En curso",  css: "bg-info-lt text-info" },
    "finished"    => { label: "Finalizado", css: "bg-secondary-lt text-secondary" }
  }.freeze

  def league_status_badge(status)
    s = LEAGUE_STATUS_STYLES[status.to_s] || { label: status.to_s, css: "bg-secondary-lt" }
    content_tag(:span, s[:label], class: "badge #{s[:css]}")
  end

  def tournament_status_badge(status)
    s = TOURNAMENT_STATUS_STYLES[status.to_s] || { label: status.to_s, css: "bg-secondary-lt" }
    content_tag(:span, s[:label], class: "badge #{s[:css]}")
  end
end
