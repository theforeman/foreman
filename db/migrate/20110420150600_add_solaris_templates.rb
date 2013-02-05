class AddSolarisTemplates < ActiveRecord::Migration
  class ConfigTemplate < ActiveRecord::Base
    has_and_belongs_to_many :operatingsystems
  end
  def self.up
    TemplateKind.create :name =>"PXEGrub"
    TemplateKind.all.each do |kind|
      case kind.name
      when /provision/
        ConfigTemplate.create(
          :name                => "Jumpstart Default",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Solaris.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/jumpstart.rhtml"))
      when /finish/
        ConfigTemplate.create(
          :name                => "Jumstart Default Finish",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Solaris.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/jumpstart_finish.rhtml"))
      when /pxegrub/i
        ConfigTemplate.create(
          :name                => "Jumpstart default PXEGrub",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Solaris.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/pxe_jumpstart_config.erb"))
      end
      snippet = "#{Rails.root}/app/views/unattended/snippets/_http_proxy.erb"
      ConfigTemplate.create(
        :name     => "HTTP proxy",
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
