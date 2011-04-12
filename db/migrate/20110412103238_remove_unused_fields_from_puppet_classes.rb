class RemoveUnusedFieldsFromPuppetClasses < ActiveRecord::Migration
  def self.up
    remove_column :puppetclasses, :nameindicator
    remove_column :puppetclasses, :operatingsystem_id
  end

  def self.down
  end
end
