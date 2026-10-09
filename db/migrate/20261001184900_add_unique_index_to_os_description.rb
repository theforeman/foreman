class AddUniqueIndexToOsDescription < ActiveRecord::Migration[7.0]
  def up
    # Normalize blank strings to NULL
    execute "UPDATE operatingsystems SET description = NULL WHERE description = ''"

    # Deduplicate: keep the oldest record (lowest id) for each description,
    # NULL out the rest
    execute <<~SQL
      UPDATE operatingsystems
      SET description = NULL
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM operatingsystems
        WHERE description IS NOT NULL
        GROUP BY description
      )
      AND description IS NOT NULL
    SQL

    add_index :operatingsystems, :description, unique: true,
      where: "description IS NOT NULL AND description != ''",
      name: "index_operatingsystems_on_description_unique"
  end

  def down
    remove_index :operatingsystems, name: "index_operatingsystems_on_description_unique"
  end
end
