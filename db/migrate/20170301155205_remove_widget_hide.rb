class RemoveWidgetHide < ActiveRecord::Migration[4.2]
  def change
    remove_column :widgets, :hide, :boolean, :default => false
  end
end
