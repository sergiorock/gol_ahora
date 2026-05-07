class CreateReceipts < ActiveRecord::Migration[8.1]
  def change
    create_table :receipts do |t|
      t.references :charge, null: false, foreign_key: true
      t.string :receipt_number
      t.datetime :issued_at
      t.string :concept

      t.timestamps
    end
  end
end
