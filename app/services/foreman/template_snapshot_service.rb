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
        "dual_stack_provision_fallback" => "IPv6",
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

    def host4dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_c7, :with_realm_freeipa,
        name: 'snapshot-ipv4-dhcp-el7',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    def host4static
      host = FactoryBot.build(:host_for_snapshots, :with_c7,
        name: 'snapshot-ipv4-static-el7',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_static)])
      define_host_params(host)
    end

    def host6dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_c7,
        name: 'snapshot-ipv6-dhcp-el7',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v6_dhcp)])
      define_host_params(host)
    end

    def host6static
      host = FactoryBot.build(:host_for_snapshots, :with_c7,
        name: 'snapshot-ipv6-static-el7',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v6_static)])
      define_host_params(host)
    end

    def host4and6dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_c7,
        name: 'snapshot-ipv4-6-dhcp-el7',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp, :with_v6_dhcp)])
      define_host_params(host)
    end

    def debian4dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_deb10,
        name: 'snapshot-ipv4-dhcp-deb10',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    def ubuntu4dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_ubuntu18,
        name: 'snapshot-ipv4-dhcp-ubuntu18',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    def ubuntu_autoinst4dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_ubuntu20,
        name: 'snapshot-ipv4-dhcp-ubuntu20',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    def ubuntu_autoinstmulti4dhcp
      nic_a = FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp, identifier: '')
      nic_b = FactoryBot.build(:nic_managed, identifier: '',
        mac: '00-f0-54-1a-7e-e1',
        ip: '192.168.42.43')

      host = FactoryBot.build(:host_for_snapshots, :with_ubuntu20,
        name: 'snapshot-ipv4-dhcp-ubuntu20',
        interfaces: [nic_a, nic_b])
      define_host_params(host)
    end

    def rhel9_dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_rhel9,
        name: 'snapshot-ipv4-dhcp-rhel9',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    def rhel10_dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_rhel10,
        name: 'snapshot-ipv4-dhcp-rhel10',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    def rocky8_dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_rocky8,
        name: 'snapshot-ipv4-dhcp-rocky8',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    def rocky9_dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_rocky9,
        name: 'snapshot-ipv4-dhcp-rocky9',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    def rocky10_dhcp
      host = FactoryBot.build(:host_for_snapshots, :with_rocky10,
        name: 'snapshot-ipv4-dhcp-rocky10',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    def windows10_dhcp
      host = FactoryBot.build(:host_for_snapshots_ipv4_dhcp_windows10,
        name: 'snapshot-ipv4-dhcp-windows10',
        interfaces: [FactoryBot.build(:nic_for_snapshots, :with_v4_dhcp)])
      define_host_params(host)
    end

    private

    def files
      @files ||= YAML.load_file(Rails.root.join('test', 'unit', 'foreman', 'renderer', 'snapshots.yaml')).fetch('files', []).map { |path| File.join(TEMPLATES_DIRECTORY, path) }
    end
  end
end
