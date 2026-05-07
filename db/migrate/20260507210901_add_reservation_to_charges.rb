class AddReservationToCharges < ActiveRecord::Migration[8.1]
  def change
    add_reference :charges, :reservation, null: true, foreign_key: true
  end
end
