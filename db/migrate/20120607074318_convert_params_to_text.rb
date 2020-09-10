class ConvertParamsToText < ActiveRecord::Migration[4.2]
  def up
    change_column 'parameters', :value, :text
    change_column 'lookup_values', :value, :text
  end

  def down
    change_column 'parameters', :value, :string, :limit => 255
    change_column 'lookup_values', :value, :string, :limit => 255
  end
end
