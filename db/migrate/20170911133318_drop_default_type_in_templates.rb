class DropDefaultTypeInTemplates < ActiveRecord::Migration[4.2]
  def up
    change_column :templates, :type, :string, :default => nil
  end

  def down
    change_column :templates, :type, :string, :default => 'Template'
  end
end
