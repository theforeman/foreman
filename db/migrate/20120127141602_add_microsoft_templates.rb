class AddMicrosoftTemplates < ActiveRecord::Migration
  def self.up
    TemplateKind.all.each do |kind|
      case kind.name
      when /provision/
        ConfigTemplate.create(
          :name                => "Waik Default",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Microsoft.all.map(&:id),
          :template            => File.read("#{RAILS_ROOT}/app/views/unattended/autowaik.xml.erb"))
      when /pxelinux/i
        ConfigTemplate.create(
          :name                => "Waik default PXELinux",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Microsoft.all.map(&:id),
          :template            => File.read("#{RAILS_ROOT}/app/views/unattended/pxe_autowaik.erb"))
      end
    end
    os = Operatingsystem.find_all_by_type "Microsoft" || Operatingsystem.name_like("microsoft")
    disk = Ptable.create :name => "Microsoft Entire C Drive", :layout =>"select disk 0 \n clean \n create partition primary \n assign letter=C \n active \n format fs=ntfs label=Windows quick "
    disk.operatingsystems = os

    Medium.reset_column_information
    medium = Medium.create :name => "Microsoft mirror", :path => "http://example.com/"
    medium.operatingsystems = os

  rescue Exception => e
    # something bad happened, but we don't want to break the migration process
    Rails.logger.warn "Failed to migrate #{e}"
    return true

  end

  def self.down
  end
end
