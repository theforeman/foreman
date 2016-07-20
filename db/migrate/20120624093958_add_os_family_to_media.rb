class AddOsFamilyToMedia < ActiveRecord::Migration[4.2]
  def up
    add_column :media, :os_family, :string, :limit => 255
    Medium.reset_column_information
    Medium.unscoped.all.each do |m|
      family = m.operatingsystems.map(&:family).uniq.first rescue nil
      m.update_attribute(:os_family, family) if family
    end
  end

  def down
    remove_column :media, :os_family
  end
end
