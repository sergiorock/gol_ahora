class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :enrollable_type, null: false
      t.bigint :enrollable_id,   null: false
      t.string :team_name,       null: false
      t.integer :status,         null: false, default: 0
      t.datetime :enrolled_at,   null: false
      t.index [:enrollable_type, :enrollable_id]
      t.index [:user_id, :enrollable_type, :enrollable_id], unique: true, name: "index_one_enrollment_per_user_per_competition"

      t.timestamps
    end
  end
end
