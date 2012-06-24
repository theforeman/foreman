class AddOsFamilyToMedia < ActiveRecord::Migration
  def self.up
    add_column :media, :os_family, :string
    Medium.reset_column_information
    Medium.all.each do |m|
      family = m.operatingsystems.map(&:family).uniq.first rescue nil
      m.update_attribute(:os_family, family) if family
    end
  end

  def self.down
    remove_column :media, :os_family
  end
end
