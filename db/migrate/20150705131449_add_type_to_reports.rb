class AddTypeToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :type, :string, :null => false, :default => 'ConfigReport', :limit => 255
  end
end
