class AddComposeFlagAndShortNameToFactName < ActiveRecord::Migration[4.2]
  def change
    add_column :fact_names, :compose, :boolean, :default => false, :null => false
    add_column :fact_names, :short_name, :string, :limit => 255
  end
end
