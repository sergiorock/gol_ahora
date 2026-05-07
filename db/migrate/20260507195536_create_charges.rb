class CreateCharges < ActiveRecord::Migration[8.1]
  def change
    create_table :charges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :discount, null: true, foreign_key: true
      t.decimal :amount, null: false
      t.string :concept, null: false
      t.integer :charge_type, null: false
      t.integer :payment_method, null: false, default: 0
      t.date :date, null: false
      t.text :notes

      t.timestamps
    end
  end
end
