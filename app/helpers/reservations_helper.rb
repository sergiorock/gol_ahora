module ReservationsHelper
  STATUS_STYLES = {
    "pending"     => { label: "Pendiente",   css: "bg-yellow-500/15 text-yellow-400 border-yellow-500/30" },
    "confirmed"   => { label: "Confirmada",  css: "bg-green-500/15 text-green-400 border-green-500/30" },
    "in_progress" => { label: "En curso",    css: "bg-blue-500/15 text-blue-400 border-blue-500/30" },
    "finished"    => { label: "Finalizada",  css: "bg-white/10 text-white/50 border-white/20" },
    "cancelled"   => { label: "Cancelada",   css: "bg-red-500/15 text-red-400 border-red-500/30" }
  }.freeze

  def reservation_status_badge(status)
    style = STATUS_STYLES[status.to_s] || { label: status.to_s.humanize, css: "bg-white/10 text-white/50" }
    content_tag(:span, style[:label],
      class: "inline-block px-2.5 py-0.5 rounded-full text-xs font-medium border #{style[:css]}")
  end
end
