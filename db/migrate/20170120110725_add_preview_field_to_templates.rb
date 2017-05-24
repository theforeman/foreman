class AddPreviewFieldToTemplates < ActiveRecord::Migration
  def up
    add_column :templates, :preview_enabled, :boolean, :default => true
  end

  def down
    remove_column :templates, :preview_enabled
  end
end
