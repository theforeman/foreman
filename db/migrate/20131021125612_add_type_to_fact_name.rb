class AddTypeToFactName < ActiveRecord::Migration
  def change
    add_column :fact_names, :type, :string, :default => 'FactName', :limit => 255
  end
end
