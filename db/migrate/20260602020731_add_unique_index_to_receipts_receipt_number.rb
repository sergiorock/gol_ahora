class AddUniqueIndexToReceiptsReceiptNumber < ActiveRecord::Migration[8.1]
  def change
    add_index :receipts, :receipt_number, unique: true
  end
end
