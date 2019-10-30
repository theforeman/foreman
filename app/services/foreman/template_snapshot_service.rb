module Foreman
  class TemplateSnapshotService
    TEMPLATES_DIRECTORY = Rails.root.join('app', 'views', 'unattended', 'provisioning_templates')

    def self.templates
      new.templates
    end

    def self.host(os_name, os_type, os_major, os_minor)
      new.host(os_name, os_type, os_major, os_minor)
    end

    def self.render_template(template, os_name, os_type, os_major, os_minor)
      host_for_template = host(os_name, os_type, os_major, os_minor)
      source = Foreman::Renderer::Source::Snapshot.new(template)
      scope = Foreman::Renderer.get_scope(host: host_for_template, source: source)
      Foreman::Renderer.render(source, scope)
    end

    def templates
      files.map { |t| [Foreman::Renderer::Source::Snapshot.load_file(File.join(TEMPLATES_DIRECTORY, t["name"])), t["os"]] }
    end

    def host(os_name, os_type, os_major, os_minor)
      interface = FactoryBot.build(:nic_primary_and_provision,
        identifier: 'eth0',
        mac: '00-f0-54-1a-7e-e0',
        ip: '127.0.0.1')
      domain = FactoryBot.build(:domain, name: 'snapshotdomain.com')
      subnet = FactoryBot.build(:subnet_ipv4, name: 'one', network: interface.ip)
      architecture = FactoryBot.build(:architecture, name: 'x86_64')
      medium = FactoryBot.build(:medium, name: 'Some mirror', path: 'http://example.com/some/path')
      ptable = FactoryBot.build(:ptable, name: 'ptable')
      operatingsystem = FactoryBot.build(:operatingsystem,
        name: os_name,
        type: os_type,
        major: os_major,
        minor: os_minor,
        architectures: [architecture],
        media: [medium],
        ptables: [ptable])
      FactoryBot.build(:host, :managed,
        hostname: 'snapshothost',
        domain: domain,
        subnet: subnet,
        architecture: architecture,
        medium: medium,
        ptable: ptable,
        operatingsystem: operatingsystem,
        interfaces: [interface])
    end

    private

    def files
      @files ||= YAML.load_file(Rails.root.join('test', 'unit', 'foreman', 'renderer', 'snapshots.yaml')).fetch('files', [])
    end
  end
end
