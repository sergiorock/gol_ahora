class ReplaceAgeWithBirthDateInUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :age, :integer
    add_column :users, :birth_date, :date
  end
end
