class AddExampleUserDataScripts < ActiveRecord::Migration
  def self.up
    TemplateKind.all.each do |kind|
      case kind.name
      when /user_data/
        ConfigTemplate.create(
          :name                => "aws_client_bootstrap",
          :template_kind_id    => kind.id,
          :operatingsystem_ids => Redhat.all.map(&:id),
          :template            => File.read("#{Rails.root}/app/views/unattended/aws_client_bootstrap.erb"))
      end

    end

    %w[_puppet.client.cloud-config.erb _puppetlabs.repo.cloud-config.erb _rpmforge.repo.cloud-config.erb _amazon.repo.cloud-config.erb _AWS_tweaks.erb _puppet.client.oneline.erb].each do |snippet|
      ConfigTemplate.create(
        :name     => snippet.gsub(/.*_/,"").gsub(".erb",""),
        :template => File.read("#{Rails.root}/app/views/unattended/snippets/#{snippet}"),
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
