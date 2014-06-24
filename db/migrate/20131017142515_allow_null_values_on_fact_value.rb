class AllowNullValuesOnFactValue < ActiveRecord::Migration
  def self.up
    change_column :fact_values, :value, :text, :null => true
  end

  def self.down
    change_column :fact_values, :value, :text, :null => false
  end
end
