class RemoveEnvironmentFromHost < ActiveRecord::Migration[4.2]
  def up
    remove_column :hosts, :environment
  end

  def down
    add_column :hosts, :environment, :text
  end
end
