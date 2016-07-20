class AddLabelToHostGroup < ActiveRecord::Migration[4.2]
  def up
    add_column :hostgroups, :label, :string, :limit => 255

    Hostgroup.reset_column_information
    execute "UPDATE hostgroups set label = name WHERE ancestry IS NULL"
    # .unscoped is needed since the default scope orders by title, but title is not a db field yet.
    Hostgroup.unscoped.where("ancestry IS NOT NULL").each do |hostgroup|
      hostgroup.label = hostgroup.get_label
      hostgroup.save_without_auditing
    end
  end

  def down
    remove_column :hostgroups, :label
  end
end
