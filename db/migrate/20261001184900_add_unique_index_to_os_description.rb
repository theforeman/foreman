class AddUniqueIndexToOsDescription < ActiveRecord::Migration[7.0]
  # Match Rails' String#blank? (\A[[:space:]]*\z) so the DB agrees with the
  # model's `allow_blank` validation: empty and whitespace-only are both "blank".
  BLANK_DESCRIPTION = "description ~ '^\\s*$'".freeze

  def up
    # Normalize blank (empty or whitespace-only) descriptions to NULL
    execute "UPDATE operatingsystems SET description = NULL WHERE #{BLANK_DESCRIPTION}"

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
      where: "description IS NOT NULL AND NOT (#{BLANK_DESCRIPTION})",
      name: "index_operatingsystems_on_description_unique"
  end

  def down
    remove_index :operatingsystems, name: "index_operatingsystems_on_description_unique"
  end
end
