module Foreman
  module UnattendedInstallation
    class MacListExtractor
      def extract_from_env(env, params: {})
        mac_list = macs_from_headers(env)
        mac_list << params[:mac].strip.downcase if params[:mac]

        mac_list
      end

      private

      def macs_from_headers(env)
        return [] unless env['HTTP_X_RHN_PROVISIONING_MAC_0'].present?

        # Search for a mac address in any of the RHN provisioning headers.
        begin
          mac_list = env.map do |key, value|
            value.split[1].strip.downcase if key =~ /^HTTP_X_RHN_PROVISIONING_MAC_/
          end
        rescue => e
          Foreman::Logging.exception("unknown RHN_PROVISIONING header", e)
          return []
        end

        mac_list.compact
      end
    end
  end
end
