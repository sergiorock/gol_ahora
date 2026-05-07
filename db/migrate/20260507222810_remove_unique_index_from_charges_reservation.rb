class RemoveUniqueIndexFromChargesReservation < ActiveRecord::Migration[8.1]
  def change
    remove_index :charges, :reservation_id
    add_index :charges, :reservation_id
    add_column :charges, :is_deposit, :boolean, null: false, default: false
    add_index :charges, [:reservation_id, :is_deposit],
              unique: true,
              where: "reservation_id IS NOT NULL AND is_deposit = false",
              name: "index_charges_one_balance_per_reservation"
  end
end
