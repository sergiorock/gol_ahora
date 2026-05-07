class AddUniqueIndexToChargesReservation < ActiveRecord::Migration[8.1]
  def change
    remove_index :charges, :reservation_id
    add_index :charges, :reservation_id, unique: true, where: "reservation_id IS NOT NULL"
  end
end
