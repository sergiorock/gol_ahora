class RestoreScheduledAtConstraints < ActiveRecord::Migration[8.1]
  def up
    # Remove any NULL rows left from the refactor rollback
    execute "DELETE FROM clases WHERE scheduled_at IS NULL"
    execute "DELETE FROM entrenamientos WHERE scheduled_at IS NULL"
    change_column_null :clases, :scheduled_at, false
    change_column_null :entrenamientos, :scheduled_at, false
  end

  def down
    change_column_null :clases, :scheduled_at, true
    change_column_null :entrenamientos, :scheduled_at, true
  end
end
