class AddPxegrubLocalbootTemplate < ActiveRecord::Migration
  class ConfigTemplate < ActiveRecord::Base
    has_and_belongs_to_many :operatingsystems
  end
  def self.up
    ConfigTemplate.create(
      :name                => "PXEGrub Localboot Default",
      :template_kind_id    => TemplateKind.find_by_name("PXEGrub").id,
      :operatingsystem_ids => [],
      :template            => File.read("#{Rails.root}/app/views/unattended/pxegrub_local.erb"))
  end

  def self.down
  end
end
