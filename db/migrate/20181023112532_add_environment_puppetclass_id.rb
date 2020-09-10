class AddEnvironmentPuppetclassId < ActiveRecord::Migration[5.2]
  def change
    add_index :environment_classes, [:environment_id, :puppetclass_id]
    remove_index :environment_classes, :environment_id
  end
end
