class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @stats = [
      [ Reservation.where.not(status: "cancelled").count, "reservas registradas" ],
      [ User.client.count, "jugadores registrados" ],
      [ Court.available.count, "canchas activas" ],
      [ "24/7", "reserva web" ]
    ]
  end
end
