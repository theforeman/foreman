module Foreman
  class TemplateSnapshotService
    TEMPLATES_DIRECTORY = Rails.root.join('app', 'views', 'unattended', 'provisioning_templates')

    def self.templates
      new.templates
    end

    def self.host
      new.host
    end

    def self.render_template(template)
      source = Foreman::Renderer::Source::Snapshot.new(template)
      scope = Foreman::Renderer.get_scope(host: host, source: source)
      Foreman::Renderer.render(source, scope)
    end

    def templates
      files.map { |path| Foreman::Renderer::Source::Snapshot.load_file(path) }
    end

    def host
      interface = FactoryBot.build(:nic_primary_and_provision, identifier: 'eth0',
                                   mac: '00-f0-54-1a-7e-e0',
                                   ip: '127.0.0.1')
      domain = FactoryBot.build(:domain, name: 'snapshotdomain.com')
      subnet = FactoryBot.build(:subnet_ipv4, name: 'one', network: interface.ip)
      architecture = FactoryBot.build(:architecture, name: 'x86_64')
      medium = FactoryBot.build(:medium, name: 'CentOS mirror')
      ptable = FactoryBot.build(:ptable, name: 'ptable')
      operatingsystem = FactoryBot.build(:operatingsystem, name: 'Redhat',
                                         major: 7,
                                         architectures: [architecture],
                                         media: [medium],
                                         ptables: [ptable])
      host = FactoryBot.build(:host, :managed, hostname: 'snapshothost',
                       domain: domain,
                       subnet: subnet,
                       architecture: architecture,
                       medium: medium,
                       ptable: ptable,
                       operatingsystem: operatingsystem,
                       interfaces: [interface])

      host_params = {
        "enable-epel" => "true",
        "package_upgrade" => "true",
        "ansible_tower_provisioning" => "true",
        "schedule_reboot" => "true",
        "fips_enabled" => "true",
        "force-puppet" => "true",
        "remote_execution_create_user" => "true",
        "blacklist_kernel_modules" => "amodule",
      }
      host_params.each_pair do |name, value|
        FactoryBot.build(:host_parameter, host: host, name: name, value: value)
      end
      host.define_singleton_method(:params) { host_params }
      host.define_singleton_method(:host_param) do |name|
        host_params[name]
      end
      host
    end

    private

    def files
      @files ||= YAML.load_file(Rails.root.join('test', 'unit', 'foreman', 'renderer', 'snapshots.yaml')).fetch('files', []).map { |path| File.join(TEMPLATES_DIRECTORY, path) }
    end
  end
end
