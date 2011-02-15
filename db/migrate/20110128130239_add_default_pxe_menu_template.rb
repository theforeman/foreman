class AddDefaultPxeMenuTemplate < ActiveRecord::Migration
  def self.up
    ConfigTemplate.create(
      :name                => "PXE Default File",
      :template_kind_id    => TemplateKind.find_by_name("PXELinux"),
      :operatingsystem_ids => [],
      :template            => File.read("#{RAILS_ROOT}/app/views/unattended/pxe_default.erb"))
  end

  def self.down
  end
end
