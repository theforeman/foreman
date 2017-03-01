class RemoveWidgetHide < ActiveRecord::Migration
  def change
    remove_column :widgets, :hide, :boolean, :default => false
  end
end
