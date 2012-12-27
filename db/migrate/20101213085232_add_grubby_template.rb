class AddGrubbyTemplate < ActiveRecord::Migration
  class ConfigTemplate < ActiveRecord::Base
    has_and_belongs_to_many :operatingsystems
  end
  def self.up
        ConfigTemplate.create(
          :name                => "Grubby Default",
          :template_kind_id    => TemplateKind.find_by_name("script").id,
          :operatingsystem_ids => Redhat.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/grubby.erb"))
  end

  def self.down
  end
end
