class AddOverlapConstraintToReservations < ActiveRecord::Migration[8.1]
  def up
    enable_extension "btree_gist"

    execute <<~SQL
      ALTER TABLE reservations
      ADD CONSTRAINT no_overlapping_reservations
      EXCLUDE USING gist (
        court_id WITH =,
        tsrange(starts_at, ends_at, '[)') WITH &&
      ) WHERE (status <> 'cancelled')
    SQL
  end

  def down
    execute "ALTER TABLE reservations DROP CONSTRAINT IF EXISTS no_overlapping_reservations"
  end
end
