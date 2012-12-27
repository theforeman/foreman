class AddSuseTemplates < ActiveRecord::Migration

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
          :name                => "YaST2 Default",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Suse.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/autoyast.xml.erb"))
      when /pxelinux/i
        ConfigTemplate.create(
          :name                => "YaST2 default PXELinux",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Suse.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/pxe_autoyast.erb"))
      end
    end
    os = Operatingsystem.find_all_by_type "Suse" || Operatingsystem.where("name LIKE ?", "suse")
    disk = Ptable.create :name => "SuSE Entire SCSI Disk", :layout =>"  <partitioning  config:type=\"list\">\n    <drive>\n      <device>/dev/sda</device>       \n      <use>all</use>\n    </drive>\n  </partitioning>"
    disk.operatingsystems = os
    disk = Ptable.create :name => "SuSE Entire Virtual Disk", :layout =>"  <partitioning  config:type=\"list\">\n    <drive>\n      <device>/dev/vda</device>       \n      <use>all</use>\n    </drive>\n  </partitioning>"
    disk.operatingsystems = os

    medium = Medium.create :name => "OpenSuSE mirror", :path => "http://mirror.isoc.org.il/pub/opensuse/distribution/$major.$minor/repo/oss"
    medium.operatingsystems = os

  rescue Exception => e
    # something bad happened, but we don't want to break the migration process
    Rails.logger.warn "Failed to migrate #{e}"
    say "Failed to migrate #{e}"
    return true

  end

  def self.down
  end
end
