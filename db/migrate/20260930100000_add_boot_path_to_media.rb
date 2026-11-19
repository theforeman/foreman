class AddBootPathToMedia < ActiveRecord::Migration[7.0]
  def up
    add_column :media, :boot_path, :string

    execute <<~SQL
      UPDATE media
      SET boot_path = 'https://releases.ubuntu.com'
      WHERE name = 'Ubuntu mirror'
        AND path = 'http://archive.ubuntu.com/ubuntu'
        AND boot_path IS NULL
    SQL
  end

  def down
    remove_column :media, :boot_path
  end
end
