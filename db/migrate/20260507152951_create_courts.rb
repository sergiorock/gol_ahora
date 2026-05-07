class CreateCourts < ActiveRecord::Migration[8.1]
  def change
    create_table :courts do |t|
      t.string :name
      t.text :description
      t.integer :status
      t.references :court_type, null: false, foreign_key: true

      t.timestamps
    end
  end
end
