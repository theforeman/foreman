class AddDefaultPxeMenuTemplate < ActiveRecord::Migration
  def self.up
    ConfigTemplate.without_auditing {ConfigTemplate.create(
      :name                => "PXE Default File",
      :template_kind_id    => TemplateKind.find_by_name("PXELinux"),
      :operatingsystem_ids => [],
      :template            => File.read("#{Rails.root}/app/views/unattended/pxe_default.erb"))}
  end

  def self.down
  end
end
