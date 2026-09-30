class AddBootPathToMedia < ActiveRecord::Migration[7.0]
  def change
    add_column :media, :boot_path, :string
  end
end
