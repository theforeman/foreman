class AddTypeToReports < ActiveRecord::Migration
  def change
    add_column :reports, :type, :string, :null => false, :default => 'ConfigReport', :limit => 255
  end
end
