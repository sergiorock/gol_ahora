class RenameSpanishColumnsInUsers < ActiveRecord::Migration[8.1]
  def change
    rename_column :users, :nombres,       :first_name
    rename_column :users, :apellido,      :last_name
    rename_column :users, :domicilio,     :address
    rename_column :users, :codigo_postal, :postal_code
    rename_column :users, :fecha_ingreso, :joined_at
    rename_column :users, :telefono,      :phone
    rename_column :users, :pais,          :country
    rename_column :users, :localidad,     :city
    rename_column :users, :edad,          :age
  end
end
