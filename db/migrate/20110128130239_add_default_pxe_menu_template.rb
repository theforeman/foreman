class AddDefaultPxeMenuTemplate < ActiveRecord::Migration
  class ConfigTemplate < ActiveRecord::Base
    has_and_belongs_to_many :operatingsystems
  end
  def self.up
    ConfigTemplate.create(
      :name                => "PXE Default File",
      :template_kind_id    => TemplateKind.find_by_name("PXELinux"),
      :operatingsystem_ids => [],
      :template            => File.read("#{Rails.root}/app/views/unattended/pxe_default.erb"))
  end

  def self.down
  end
end
