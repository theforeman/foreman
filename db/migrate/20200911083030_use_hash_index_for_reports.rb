class UseHashIndexForReports < ActiveRecord::Migration[6.0]
  def change
    remove_index(:messages, :digest)
    remove_index(:sources, :digest)
    remove_column(:messages, :digest, :string, :limit => 40)
    remove_column(:sources, :digest, :string, :limit => 40)

    add_index(:messages, :value, using: 'hash')
    add_index(:sources, :value, using: 'hash')
  end
end
