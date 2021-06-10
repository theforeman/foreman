module Foreman
  class TemplateSnapshotService
    TEMPLATES_DIRECTORY = Rails.root.join('app', 'views', 'unattended', 'provisioning_templates')

    def self.templates
      new.templates
    end

    def self.host4dhcp
      new.host4dhcp
    end

    def self.host6dhcp
      new.host6dhcp
    end

    def self.host4and6dhcp
      new.host4and6dhcp
    end

    def self.host4static
      new.host4static
    end

    def self.host6static
      new.host6static
    end

    def self.debian4dhcp
      new.debian4dhcp
    end

    def self.ubuntu4dhcp
      new.ubuntu4dhcp
    end

    def self.render_template(template, host_name = :host4dhcp)
      host_stub = send(host_name.to_sym)
      source = Foreman::Renderer::Source::Snapshot.new(template)
      scope = Foreman::Renderer.get_scope(host: host_stub, source: source)
      Foreman::Renderer.render(source, scope)
    end

    def templates
      files.map { |path| Foreman::Renderer::Source::Snapshot.load_file(path) }
    end

    def host4dhcp
      FactoryBot.build(:snapshot_host,
        :with_snapshot_dhcp4,
        :with_snapshot_os_el7,
        :with_snapshot_puppet)
    end

    def host4static
      FactoryBot.build(:snapshot_host,
        :with_snapshot_static4,
        :with_snapshot_os_el7,
        :with_snapshot_puppet)
    end

    def host6dhcp
      FactoryBot.build(:snapshot_host,
        :with_snapshot_dhcp6,
        :with_snapshot_os_el7,
        :with_snapshot_puppet)
    end

    def host6static
      FactoryBot.build(:snapshot_host,
        :with_snapshot_static6,
        :with_snapshot_os_el7,
        :with_snapshot_puppet)
    end

    def host4and6dhcp
      FactoryBot.build(:snapshot_host,
        :with_snapshot_dhcp_dualstack,
        :with_snapshot_os_el7,
        :with_snapshot_puppet)
    end

    def debian4dhcp
      FactoryBot.build(:snapshot_host,
        :with_snapshot_dhcp_dualstack,
        :with_snapshot_os_debian10,
        :with_snapshot_puppet)
    end

    def ubuntu4dhcp
      FactoryBot.build(:snapshot_host,
        :with_snapshot_dhcp_dualstack,
        :with_snapshot_os_ubuntu20,
        :with_snapshot_puppet)
    end

    private

    def files
      @files ||= YAML.load_file(Rails.root.join('test', 'unit', 'foreman', 'renderer', 'snapshots.yaml')).fetch('files', []).map { |path| File.join(TEMPLATES_DIRECTORY, path) }
    end
  end
end
