class AddOsFamilyToPtable < ActiveRecord::Migration
  def self.up
    add_column :ptables, :os_family, :string
    remove_column :ptables, :operatingsystem_id
    Ptable.reset_column_information
    Ptable.all.each do |p|
      family = p.operatingsystems.map(&:family).uniq.first rescue nil
      p.update_attribute(:os_family, family) if family
    end

  end

  def self.down
    remove_column :ptables, :os_family
    add_column :ptables, :operatingsystem_id, :integer
  end
end
