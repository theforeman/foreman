class IndexForeignKeysInOperatingsystemsPuppetclasses < ActiveRecord::Migration[5.1]
  def change
    add_index :operatingsystems_puppetclasses, :operatingsystem_id
    add_index :operatingsystems_puppetclasses, :puppetclass_id
  end
end
