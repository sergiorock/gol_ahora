class CreateAsistencias < ActiveRecord::Migration[8.1]
  def change
    create_table :asistencias do |t|
      t.references :user, null: false, foreign_key: true
      t.references :asistible, polymorphic: true, null: false
      t.date :attended_on
      t.boolean :present, default: false, null: false

      t.timestamps
    end
  end
end
