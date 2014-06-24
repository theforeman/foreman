class ConvertParamsToText < ActiveRecord::Migration
  def self.up
    change_column 'parameters', :value, :text
    change_column 'lookup_values', :value, :text
  end

  def self.down
    change_column 'parameters', :value, :string
    change_column 'lookup_values', :value, :string
  end
end
