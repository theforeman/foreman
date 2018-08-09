class IndexForeignKeysInHostClasses < ActiveRecord::Migration[5.1]
  def change
    add_index :host_classes, :host_id
    add_index :host_classes, :puppetclass_id
  end
end
