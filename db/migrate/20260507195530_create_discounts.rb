class CreateDiscounts < ActiveRecord::Migration[8.1]
  def change
    create_table :discounts do |t|
      t.string :name, null: false
      t.integer :discount_type, null: false
      t.decimal :value, null: false
      t.string :condition
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
