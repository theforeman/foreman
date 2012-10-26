class AddLocalbootTemplate < ActiveRecord::Migration
  def self.up
    ConfigTemplate.without_auditing {ConfigTemplate.create(
      :name                => "PXE Localboot Default",
      :template_kind_id    => TemplateKind.find_by_name("PXELinux"),
      :operatingsystem_ids => [],
      :template            => File.read("#{Rails.root}/app/views/unattended/pxe_local.erb"))}
  end

  def self.down
  end
end
