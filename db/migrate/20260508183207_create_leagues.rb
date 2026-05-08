class CreateLeagues < ActiveRecord::Migration[8.1]
  def change
    create_table :leagues do |t|
      t.string :name, null: false
      t.text :description
      t.date :start_date
      t.date :end_date
      t.integer :status, null: false, default: 0
      t.text :rules

      t.timestamps
    end
  end
end
