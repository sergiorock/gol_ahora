class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :reservation, null: false, foreign_key: true
      t.decimal :amount
      t.integer :payment_type
      t.integer :status
      t.string :last_four_digits
      t.string :cardholder_name
      t.string :expiry_date

      t.timestamps
    end
  end
end
