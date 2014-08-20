class ChangeTitleColumnsToText < ActiveRecord::Migration
  def up
    change_column :hostgroups, :title, :text
    change_column :taxonomies, :title, :text
  end

  def down
    change_column :hostgroups, :title, :string
    change_column :taxonomies, :title, :string
  end
end
