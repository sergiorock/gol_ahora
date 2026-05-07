class CreateReservations < ActiveRecord::Migration[8.1]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :court, null: false, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :status
      t.decimal :total_amount
      t.decimal :deposit_amount
      t.text :notes

      t.timestamps
    end

    add_index :reservations, [ :court_id, :starts_at, :ends_at ]
  end
end
