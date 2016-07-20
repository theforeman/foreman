class AddTypeToFactName < ActiveRecord::Migration[4.2]
  def change
    add_column :fact_names, :type, :string, :default => 'FactName', :limit => 255
  end
end
