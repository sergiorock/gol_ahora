class CreateMatches < ActiveRecord::Migration[8.1]
  def change
    create_table :matches do |t|
      t.string :competition_type
      t.bigint :competition_id
      t.index [:competition_type, :competition_id]
      t.references :court, null: true, foreign_key: true
      t.string :home_team
      t.string :away_team
      t.integer :home_goals
      t.integer :away_goals
      t.datetime :played_at
      t.text :official_rules

      t.timestamps
    end
  end
end
