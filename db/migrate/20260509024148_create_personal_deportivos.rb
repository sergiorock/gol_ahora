class CreatePersonalDeportivos < ActiveRecord::Migration[8.1]
  def change
    create_table :personal_deportivos do |t|
      t.string :nombre
      t.string :apellido
      t.string :email
      t.string :telefono
      t.integer :tipo
      t.string :certificacion_deportiva
      t.date :fecha_certificacion
      t.text :observaciones

      t.timestamps
    end
  end
end
