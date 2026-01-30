module Foreman
  class TemplateSnapshotService
    TEMPLATES_DIRECTORY = Rails.root.join('app', 'views', 'unattended', 'provisioning_templates')

    def self.templates
      new.templates
    end

    def self.render_template(template, host_name = :host4dhcp)
      host_stub = new.send(host_name.to_sym)
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
        "kdump-options" => "--disable",
        "package_upgrade" => "true",
        "ansible_tower_provisioning" => "true",
        "ansible_tower_api_url" => "https://host.example.com/api/controller/v2",
        "ansible_job_template_id" => "20",
        "schedule_reboot" => "true",
        "fips_enabled" => "true",
        "force-puppet" => "true",
        "remote_execution_create_user" => "true",
        "blacklist_kernel_modules" => "amodule",
        "subscription_manager" => "true",
        "subscription_manager_org" => "Org",
        "subscription_manager_status" => "true",
        "subscription_manager_refresh" => "true",
        "subscription_manager_refresh_force" => "true",
        "activation_key" => "key",
        "host_registration_insights" => "true",
        "syspurpose_role" => "Red Hat Enterprise Linux Server",
        "syspurpose_usage" => "Development/Test",
        "syspurpose_sla" => "Self-Support",
        "ansible_user" => "win_ansible_user",
        "create_ansible_user" => "true",
        "ansible_ssh_pass" => "win_ansible_user_ssh_pass",
        "remote_desktop" => "true",
        "realm" => "true",
        "ntp-pools" => ['first.ntp-pool', 'second.ntp-pool'],
        "ntp-server" => "first.ntp.server",
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
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7, :with_realm_freeipa,
        name: 'snapshot-ipv4-dhcp-el7',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def host4static
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7,
        name: 'snapshot-ipv4-static-el7',
        subnet: FactoryBot.build(:subnet_ipv4_static_for_snapshots),
        interfaces: [ipv4_interface])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def host6dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7,
        name: 'snapshot-ipv6-dhcp-el7',
        subnet: FactoryBot.build(:subnet_ipv6_dhcp_for_snapshots),
        interfaces: [ipv6_interface])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def host6static
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7,
        name: 'snapshot-ipv6-static-el7',
        subnet: FactoryBot.build(:subnet_ipv6_static_for_snapshots),
        interfaces: [ipv6_interface])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def host4and6dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_el7,
        name: 'snapshot-ipv4-6-dhcp-el7',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        subnet6: FactoryBot.build(:subnet_ipv6_dhcp_for_snapshots),
        interfaces: [ipv46_interface])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def debian4dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_deb10,
        name: 'snapshot-ipv4-dhcp-deb10',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def ubuntu4dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_ubuntu18,
        name: 'snapshot-ipv4-dhcp-ubuntu18',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      define_host_params(host)
    end

    def ubuntu_autoinst4dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_ubuntu20,
        name: 'snapshot-ipv4-dhcp-ubuntu20',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def ubuntu_autoinstmulti4dhcp
      nic_a = FactoryBot.build(:nic_primary_and_provision, identifier: '',
        mac: '00-f0-54-1a-7e-e0',
        ip: '192.168.42.42')
      nic_b = FactoryBot.build(:nic_managed, identifier: '',
        mac: '00-f0-54-1a-7e-e1',
        ip: '192.168.42.43')

      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_ubuntu20,
        name: 'snapshot-ipv4-dhcp-ubuntu20',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [nic_a, nic_b])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def rhel9_dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_rhel9,
        name: 'snapshot-ipv4-dhcp-rhel9',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def rhel10_dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_rhel10,
        name: 'snapshot-ipv4-dhcp-rhel10',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      host.define_singleton_method(:managed_interfaces) { interfaces }
      define_host_params(host)
    end

    def rocky8_dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_rocky8,
        name: 'snapshot-ipv4-dhcp-rocky8',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      define_host_params(host)
    end

    def rocky9_dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_rocky9,
        name: 'snapshot-ipv4-dhcp-rocky9',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      define_host_params(host)
    end

    def rocky10_dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_rocky10,
        name: 'snapshot-ipv4-dhcp-rocky10',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      define_host_params(host)
    end

    def windows10_dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_windows10,
        name: 'snapshot-ipv4-dhcp-windows10',
        subnet: FactoryBot.build(:subnet_ipv4_dhcp_for_snapshots),
        interfaces: [ipv4_interface])
      define_host_params(host)
    end

    private

    def files
      @files ||= YAML.load_file(Rails.root.join('test', 'unit', 'foreman', 'renderer', 'snapshots.yaml')).fetch('files', []).map { |path| File.join(TEMPLATES_DIRECTORY, path) }
    end
  end
end
