class AddGrubbyTemplate < ActiveRecord::Migration
  def self.up
        ConfigTemplate.without_auditing { ConfigTemplate.create(
          :name                => "Grubby Default",
          :template_kind_id    => TemplateKind.find_by_name("script").id,
          :operatingsystem_ids => Redhat.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/grubby.erb"))}
  end

  def self.down
  end
end
