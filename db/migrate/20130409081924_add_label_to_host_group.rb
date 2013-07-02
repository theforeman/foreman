class AddLabelToHostGroup < ActiveRecord::Migration

  def self.up
    add_column :hostgroups, :label, :string

    Hostgroup.reset_column_information
    execute "UPDATE hostgroups set label = name WHERE ancestry IS NULL"
    Hostgroup.where("ancestry IS NOT NULL").each do |hostgroup|
      hostgroup.label = hostgroup.get_label
      hostgroup.save_without_auditing
    end
  end

  def self.down
    remove_column :hostgroups, :label
  end

end
