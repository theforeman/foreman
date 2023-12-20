module Foreman
  module Renderer
    module Scope
      module Macros
        module Kickstart
          include Foreman::Renderer::Errors
          extend ApipieDSL::Module

          apipie :class, desc: 'Macros to use within a kickstart template' do
            name 'Kickstart'
            sections only: %w[all]
          end

          # For more information about KS network directive: https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html#network
          apipie :method, "Returns a kickstart 'network' directive for a specific interface" do
            required :iface, Nic::Managed, "Managed interface object to represent"
            keyword :host, Host::Managed, "The host that is being provisioned"
            keyword :use_slaac, [true, false], "Is the interface configured using SLAAC"
            keyword :static, [true, false], "Use static configuration for IPv4"
            keyword :static6, [true, false], "Use static configuration for IPv6"
            returns String, "'network' directive with all switches that represent the input NIC object"
            example 'kickstart_network(iface, host: @host, use_slaac: false, static: false, static6: false) #=> "network --bootproto=dhcp --device=ens3"'
          end
          def kickstart_network(iface, host:, use_slaac:, static:, static6:)
            return nil unless iface.is_a?(Nic::Managed)

            network_options = []
            nameservers = []
            subnet4 = iface.subnet
            subnet6 = iface.subnet6

            # device and hostname
            if iface.bond?
              network_options.push("--device=#{iface.identifier}")
            else
              network_options.push("--device=#{iface.mac || iface.identifier}")
            end
            network_options.push("--hostname #{@host.name}")

            # single stack
            if subnet4 && !subnet6
              network_options.push("--noipv6")
            elsif !subnet4 && subnet6
              network_options.push("--noipv4")
            end

            # dual stack MTU check
            raise("IPv4 and IPv6 subnets have different MTU") if subnet4 && subnet6 && subnet4.mtu.present? && subnet6.mtu.present? && subnet4.mtu != subnet6.mtu

            # mtu method is taking into account both ipv4 and ipv6 stacks
            network_options.push("--mtu=#{iface.mtu}") if iface.mtu

            # IPv4
            if subnet4
              if !subnet4.dhcp_boot_mode? || static
                network_options.push("--bootproto static")
                network_options.push("--ip=#{iface.ip}")
                network_options.push("--netmask=#{subnet4.mask}")
                network_options.push("--gateway=#{subnet4.gateway}")
              elsif subnet4.dhcp_boot_mode?
                network_options.push("--bootproto dhcp")
              end

              nameservers.concat(subnet4.dns_servers)
            end

            # IPv6
            if subnet6
              if !subnet6.dhcp_boot_mode? || static6
                network_options.push("--ipv6=#{iface.ip6}/#{subnet6.cidr}")
                network_options.push("--ipv6gateway=#{subnet6.gateway}")
              elsif subnet6.dhcp_boot_mode?
                if use_slaac
                  network_options.push("--ipv6 auto")
                else
                  network_options.push("--ipv6 dhcp")
                end
              end

              nameservers.concat(subnet6.dns_servers)
            end

            # bond
            if iface.bond?
              bond_slaves = iface.attached_devices_identifiers.join(',')
              network_options.push("--bondslaves=#{bond_slaves}")
              network_options.push("--bondopts=mode=#{iface.mode},#{iface.bond_options.tr(' ', ',')}")
            end

            # VLAN (only on physical is recognized)
            if iface.virtual? && iface.tag.present? && iface.attached_to.present?
              network_options.push("--vlanid=#{iface.tag}")
              network_options.push("--interfacename=vlan#{iface.tag}") if host.operatingsystem.meets_requirement(fedora: 21, rhel: 7)
            end

            # DNS
            if nameservers.empty?
              network_options.push("--nodns")
            else
              network_options.push("--nameserver=#{nameservers.join(',')}")
            end

            # Search domain - available from Fedora 39 (RHEL 10)
            if iface.domain && host.operatingsystem.meets_requirement(fedora: 39, rhel: 10)
              network_options.push("--ipv4-dns-search=#{iface.domain}") if subnet4
              network_options.push("--ipv6-dns-search=#{iface.domain}") if subnet6
            end

            "network #{network_options.join(' ')}"
          end
        end
      end
    end
  end
end
