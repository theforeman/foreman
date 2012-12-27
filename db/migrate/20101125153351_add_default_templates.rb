class AddDefaultTemplates < ActiveRecord::Migration
  class ConfigTemplate < ActiveRecord::Base
    has_and_belongs_to_many :operatingsystems
  end
  def self.up
    TemplateKind.all.each do |kind|
      case kind.name
      when /provision/
        ConfigTemplate.create(
          :name                => "Kickstart Default",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Redhat.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/kickstart.rhtml"))
        ConfigTemplate.create(
          :name                => "Preseed Default",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Debian.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/preseed.rhtml"))
      when /finish/
        ConfigTemplate.create(
          :name                => "Preseed Default Finish",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Debian.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/preseed_finish.rhtml"))
      when /pxelinux/i
        ConfigTemplate.create(
          :name                => "Kickstart default PXElinux",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Redhat.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/pxe_kickstart_config.erb"))
        ConfigTemplate.create(
          :name                => "Preseed default PXElinux",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Debian.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/pxe_debian_config.erb"))
      when /gpxe/i
        ConfigTemplate.create(
          :name                => "Kickstart default gPXE",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Redhat.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/gpxe_kickstart_config.erb"))
      end

    end
    Dir["#{Rails.root}/app/views/unattended/snippets/*"].each do |snippet|
      ConfigTemplate.create(
        :name     => snippet.gsub(/.*\/_/,"").gsub(".erb",""),
        :template => File.read(snippet),
        :snippet  => true)
    end
  rescue Exception => e
    # something bad happened, but we don't want to break the migration process
    Rails.logger.warn "Failed to migrate #{e}"
    return true
  end

  def self.down
  end
end
