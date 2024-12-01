require 'ipaddr'

module Foreman
  module UnattendedInstallation
    class HostFinder
      attr_reader :query_params

      def initialize(options = {})
        @query_params = options[:query_params]
      end

      # lookup for a host based on the ip address and if possible by a mac address(as sent by anaconda)
      # if the host was found than its record will be in @host
      # if the host doesn't exists, it will return 404 and the requested method will not be reached.
      def search
        host = find_host_by_spoof || find_host_by_token
        host ||= find_host_by_ip_or_mac unless token_from_params.present?

        host
      end

      private

      def find_host_by_spoof
        host = Host.authorized('view_hosts').joins(:primary_interface).where(nics: {ip: query_params['spoof']}).first if query_params['spoof'].present?
        host ||= Host.authorized('view_hosts').find_by_name(query_params['hostname']) if query_params['hostname'].present?
        @spoof = host.present?
        host
      end

      def token_from_params
        return unless (token = query_params[:token])

        # Quirk: ZTP requires the .slax suffix
        if (result = token.match(/^([a-z0-9-]+)(.slax)$/i))
          return result[1]
        end

        token
      end

      def find_host_by_token
        return unless (token = token_from_params)

        return Host.for_token_when_built(token).first if query_params[:built]

        Host.for_token(token).first
      end

      def find_host_by_ip_or_mac
        # In-case we get back multiple ips (see #1619)
        address_parser = IPAddr.new query_params[:ip].split(',').first
        ip = address_parser.native.to_s

        mac_list = query_params[:mac_list]

        # create base query
        hosts = Host.joins(:provision_interface).order(:created_at)
        # filter the records either by mac or by the IP address
        if mac_list.empty?
          hosts = hosts.where(:nics => { :ip => ip }).or(hosts.where(:nics => { :ip6 => ip }))
        else
          hosts = hosts.where("lower(nics.mac) IN (?)", mac_list)
        end

        Rails.logger.warn("Multiple hosts found with #{ip} or #{mac_list}, picking up the most recent") if hosts.count > 1

        return unless hosts.present?

        # We return the last host and reload it since it is readonly because of associations.
        hosts.last.reload
      end
    end
  end
end
