class ConvertParamsToText < ActiveRecord::Migration
  def self.up
    change_column 'parameters', :value, :text, :limit => false
    change_column 'lookup_values', :value, :text, :limit => false
  end

  def self.down
    change_column 'parameters', :value, :string
    change_column 'lookup_values', :value, :string
  end
end
