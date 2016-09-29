class AddComposeFlagAndShortNameToFactName < ActiveRecord::Migration
  def change
    add_column :fact_names, :compose, :boolean, :default => false, :null => false
    add_column :fact_names, :short_name, :string, :limit => 255
  end
end
