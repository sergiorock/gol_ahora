class AddProvinceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :province, :string
  end
end
