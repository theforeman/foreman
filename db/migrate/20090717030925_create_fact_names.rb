class CreateFactNames < ActiveRecord::Migration
  def self.up
    create_table :fact_names do |t|
      t.string   "name",       :default => "", :null => false
      t.timestamps
    end
    add_index "fact_names", ["id"], :name => "index_fact_names_on_id"
    add_index "fact_names", ["name"], :name => "index_fact_names_on_name"
  end

  def self.down
    drop_table :fact_names
  end
end
