class CreateFactValues < ActiveRecord::Migration
  def self.up
    create_table :fact_values do |t|
      t.text     "value",        :default => "", :null => false
      t.integer  "fact_name_id",                 :null => false
      t.integer  "host_id",                      :null => false
      t.timestamps
    end
    add_index "fact_values", ["id"], :name => "index_fact_values_on_id"
    add_index "fact_values", ["fact_name_id"], :name => "index_fact_values_on_fact_name_id"
    add_index "fact_values", ["host_id"], :name => "index_fact_values_on_host_id"
  end

  def self.down
    drop_table :fact_values
  end
end
