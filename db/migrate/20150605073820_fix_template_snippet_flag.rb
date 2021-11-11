class FixTemplateSnippetFlag < ActiveRecord::Migration[4.2]
  def up
    change_column :templates, :snippet, :boolean, :default => false, :null => false
  end

  def down
    change_column :templates, :snippet, :boolean, :null => true
  end
end
