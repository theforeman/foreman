class RemoveUnusedFieldsFromPuppetClasses < ActiveRecord::Migration
  def up
    remove_column :puppetclasses, :nameindicator
    remove_column :puppetclasses, :operatingsystem_id
  end

  def down
  end
end
