class CreateEntrenamientos < ActiveRecord::Migration[8.1]
  def change
    create_table :entrenamientos do |t|
      t.string :nombre, null: false
      t.text :descripcion
      t.datetime :scheduled_at, null: false
      t.integer :duration_minutes, null: false
      t.integer :max_students, null: false
      t.references :personal_deportivo, null: false, foreign_key: true
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
