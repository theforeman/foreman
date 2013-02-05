class AddWindowsTemplates < ActiveRecord::Migration

  class Medium < ActiveRecord::Base
    has_and_belongs_to_many :operatingsystems
  end
  class ConfigTemplate < ActiveRecord::Base
    has_and_belongs_to_many :operatingsystems
  end

  def self.up
    TemplateKind.all.each do |kind|
      case kind.name
      when /provision/
        ConfigTemplate.create(
          :name                => "Waik Default",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Windows.all.map(&:id),
          :template            => File.read("#{RAILS_ROOT}/app/views/unattended/autowaik.xml.erb"))
      when /pxelinux/i
        ConfigTemplate.create(
          :name                => "Waik default PXELinux",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Windows.all.map(&:id),
          :template            => File.read("#{RAILS_ROOT}/app/views/unattended/pxe_autowaik.erb"))
      end
    end
    os = Operatingsystem.find_all_by_type "Windows" || Operatingsystem.where("name LIKE ?", "windows")
    disk = Ptable.create :name => "Windows Entire SCSI Disk", :layout =>"  <partitioning  config:type=\"list\">\n    <drive>\n      <device>/stuff</device>       \n      <use>all</use>\n    </drive>\n  </partitioning>"
    disk.operatingsystems = os
    disk = Ptable.create :name => "Windows Entire Virtual Disk", :layout =>"  <partitioning  config:type=\"list\">\n    <drive>\n      <device>/data</device>       \n      <use>all</use>\n    </drive>\n  </partitioning>"
    disk.operatingsystems = os

    Medium.reset_column_information
    medium = Medium.create :name => "Windows mirror", :path => "http://example.com/"
    medium.operatingsystems = os

  rescue Exception => e
    # something bad happened, but we don't want to break the migration process
    Rails.logger.warn "Failed to migrate #{e}"
    return true

  end

  def self.down
  end
end

