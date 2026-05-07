class CreateCourtTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :court_types do |t|
      t.string :name
      t.string :surface
      t.integer :capacity
      t.integer :max_duration_minutes
      t.decimal :price_per_hour

      t.timestamps
    end
  end
end
