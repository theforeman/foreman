# TRANSLATORS: do not translate
desc <<-END_DESC
  Orchestration maintainance tasks.

  WARNING: Always backup server data (e.g. DHCP leases file, DNS journal files)
  prior running these tasks. They do nothing by default, unless perform=1 is
  specified.

  Examples:
  rake orchestration:dhcp:add_missing subnet_name=NAME
    Preview missing DHCP records on a DHCP Smart Proxy.

  rake orchestration:dhcp:add_missing subnet_name=NAME perform=1
    Do create missing DHCP records on a DHCP Smart Proxy.

  rake orchestration:dhcp:remove_offending subnet_name=NAME
    Preview offending DHCP records on a DHCP Smart Proxy.

  rake orchestration:dhcp:remove_offending subnet_name=NAME perform=1
    Do remove offending DHCP records on a DHCP Smart Proxy.
END_DESC

def fetch_subnet(subnet_name)
  subnet = Subnet.unscoped.find_by_name(subnet_name)
  raise("Subnet '#{subnet_name}' not found") unless subnet
  raise("Subnet '#{subnet_name}' has no DHCP proxy associated") unless subnet.dhcp_proxy
  subnet
end

def fetch_dhcp_records(subnet)
  subnet.dhcp_proxy.subnet(subnet.network)["reservations"].map do |rec|
    Net::DHCP::Record.new(rec.merge(proxy: subnet.dhcp_proxy, network: subnet.network))
  end
end

namespace :orchestration do
  namespace :dhcp do
    task :add_missing => :environment do
      User.as_anonymous_admin do
        dry_run = (ENV['perform'] != '1')
        subnet = fetch_subnet(ENV['subnet_name'])
        # Create missing records on DHCP proxy
        dhcp_records = fetch_dhcp_records(subnet)
        subnet.hosts.where(type: "Host::Managed").each do |host|
          host.provision_interface.dhcp_records.each do |host_record|
            Rails.logger.debug "Checking host #{host} (#{host.mac})"
            if dhcp_records.include?(host_record)
              Rails.logger.info "Host #{host} is up-to-date"
            else
              Rails.logger.warn "Host #{host} needs config rebuild"
              host.recreate_config unless dry_run
            end
          end
        end
      end
    end

    task :remove_offending => :environment do
      User.as_anonymous_admin do
        dry_run = (ENV['perform'] != '1')
        subnet = fetch_subnet(ENV['subnet_name'])
        # Delete offending records from DHCP proxy
        dhcp_records = fetch_dhcp_records(subnet)
        dhcp_records.each do |dhcp_record|
          Rails.logger.debug "Checking DHCP record #{dhcp_record}"
          if subnet.id == Nic::Managed.unscoped.find_by_mac(dhcp_record.mac).try(:subnet_id)
            Rails.logger.info "DHCP record #{dhcp_record} is up-to-date"
          else
            Rails.logger.warn "DHCP record #{dhcp_record} not found in DB, deleting"
            subnet.dhcp_proxy.delete(subnet.network, dhcp_record.mac) unless dry_run
          end
        end
      end
    end
  end
end
