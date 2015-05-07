class ConvertParamsToText < ActiveRecord::Migration
  def up
    change_column 'parameters', :value, :text
    change_column 'lookup_values', :value, :text
  end

  def down
    change_column 'parameters', :value, :string
    change_column 'lookup_values', :value, :string
  end
end
