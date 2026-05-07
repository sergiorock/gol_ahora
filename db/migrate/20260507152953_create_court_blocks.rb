class CreateCourtBlocks < ActiveRecord::Migration[8.1]
  def change
    create_table :court_blocks do |t|
      t.references :court, null: false, foreign_key: true
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :reason

      t.timestamps
    end
  end
end
