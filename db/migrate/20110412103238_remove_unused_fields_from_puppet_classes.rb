class RemoveUnusedFieldsFromPuppetClasses < ActiveRecord::Migration[4.2]
  def up
    remove_column :puppetclasses, :nameindicator
    remove_column :puppetclasses, :operatingsystem_id
  end

  def down
  end
end
