class AddTypeToReports < ActiveRecord::Migration
  def change
    add_column :reports, :type, :string, :null => false, :default => 'ConfigReport'
  end
end
