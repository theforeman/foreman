class FreebsdOsSupport < ActiveRecord::Migration

  class Medium < ActiveRecord::Base
    has_and_belongs_to_many :operatingsystems
  end

  class ConfigTemplate < ActiveRecord::Base
    has_and_belongs_to_many :operatingsystems
  end

  def up
    TemplateKind.all.each do |kind|
      case kind.name
        when /provision/
          ConfigTemplate.create(
              :name                => "Memdisk Default",
              :template_kind_id    => kind.id,
              :operatingsystem_ids => Freebsd.all.map(&:id),
              :template            => File.read("#{Rails.root}/app/views/unattended/memdisk.rhtml"))
        when /finish/
          ConfigTemplate.create(
              :name                => "Memdisk Default Finish",
              :template_kind_id    => kind.id,
              :operatingsystem_ids => Freebsd.all.map(&:id),
              :template            => File.read("#{Rails.root}/app/views/unattended/memdisk_finish.rhtml"))
        when /pxelinux/i
          ConfigTemplate.create(
              :name                => "Memdisk default PXElinux",
              :template_kind_id    => kind.id,
              :operatingsystem_ids => Freebsd.all.map(&:id),
              :template            => File.read("#{Rails.root}/app/views/unattended/pxe_memdisk_config.erb"))
        end
    end

    os = Operatingsystem.find_all_by_type "Freebsd" || Operatingsystem.where("name LIKE ?", "freebsd")
    disk = Ptable.create :name => "FreeBSD Disk small", :layout => "# Disk Setup\ndisk0=ada0\npartition=ALL\nbootManager=bsd\npartscheme=GPT\ncommitDiskPart\n\n# Partition Setup for da0(ALL)\n# All sizes are expressed in MB\n# Avail FS Types, UFS, UFS+S, UFS+SUJ, UFS+J, ZFS, SWAP\n# UFS.eli, UFS+S.eli, UFS+SUJ, UFS+J.eli, ZFS.eli, SWAP.eli\ndisk0-part=UFS+SUJ 1000 /\ndisk0-part=SWAP 512 none\ndisk0-part=UFS+SUJ 512 /var\ncommitDiskLabel"

    medium = Medium.create :name => "FreeBSD mirror", :path => "ftp://ftp.freebsd.org/pub/FreeBSD"
    medium.operatingsystems = os

  rescue Exception => e
    # something bad happened, but we don't want to break the migration process
    Rails.logger.warn "Failed to migrate #{e}"
    say "Failed to migrate #{e}"
    return true

  end

  def down
  end
end
