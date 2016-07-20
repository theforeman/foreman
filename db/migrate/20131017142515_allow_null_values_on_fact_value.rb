class AllowNullValuesOnFactValue < ActiveRecord::Migration[4.2]
  def up
    change_column :fact_values, :value, :text, :null => true
  end

  def down
    change_column :fact_values, :value, :text, :null => false
  end
end
