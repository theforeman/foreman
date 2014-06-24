class AddTypeToFactName < ActiveRecord::Migration
  def change
    add_column :fact_names, :type, :string, :default => 'FactName'
  end
end
