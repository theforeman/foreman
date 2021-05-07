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

    def self.render_template(template, host_name = :host4dhcp)
      host_stub = send(host_name.to_sym)
      source = Foreman::Renderer::Source::Snapshot.new(template)
      scope = Foreman::Renderer.get_scope(host: host_stub, source: source)
      Foreman::Renderer.render(source, scope)
    end

    def templates
      files.map { |path| Foreman::Renderer::Source::Snapshot.load_file(path) }
    end

    def define_host_params(host)
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

    def ipv4_interface
      FactoryBot.build(:nic_primary_and_provision, identifier: 'eth0',
        mac: '00-f0-54-1a-7e-e0',
        ip: '192.168.42.42')
    end

    def ipv6_interface
      FactoryBot.build(:nic_primary_and_provision, identifier: 'eth0',
        mac: '00-f0-54-1a-7e-e0',
        ip: '2001:db8:42::42')
    end

    def ipv46_interface
      FactoryBot.build(:nic_primary_and_provision, identifier: 'eth0',
        mac: '00-f0-54-1a-7e-e0',
        ip: '192.168.42.42',
        ip6: '2001:db8:42::42')
    end

    def host4dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7,
        name: 'snapshot-ipv4-dhcp-el7',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      define_host_params(host)
    end

    def host4static
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7,
        name: 'snapshot-ipv4-static-el7',
        subnet: FactoryBot.build(:subnet_ipv4_static_for_snapshots),
        interfaces: [ipv4_interface])
      define_host_params(host)
    end

    def host6dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7,
        name: 'snapshot-ipv6-dhcp-el7',
        subnet: FactoryBot.build(:subnet_ipv6_dhcp_for_snapshots),
        interfaces: [ipv6_interface])
      define_host_params(host)
    end

    def host6static
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7,
        name: 'snapshot-ipv6-static-el7',
        subnet: FactoryBot.build(:subnet_ipv6_static_for_snapshots),
        interfaces: [ipv6_interface])
      define_host_params(host)
    end

    def host4and6dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7,
        name: 'snapshot-ipv4-6-dhcp-el7',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        subnet6: FactoryBot.build(:subnet_ipv6_dhcp_for_snapshots),
        interfaces: [ipv46_interface])
      define_host_params(host)
    end

    private

    def files
      @files ||= YAML.load_file(Rails.root.join('test', 'unit', 'foreman', 'renderer', 'snapshots.yaml')).fetch('files', []).map { |path| File.join(TEMPLATES_DIRECTORY, path) }
    end
  end
end
