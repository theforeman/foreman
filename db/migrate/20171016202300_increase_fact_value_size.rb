class IncreaseFactValueSize < ActiveRecord::Migration
  def up
    change_column :fact_values, :value, :text, :limit => 16.megabytes - 1
  end
end
