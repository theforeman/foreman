module Resolvers
  module Host
    class PowerStatus < Resolvers::BaseResolver
      type Types::RawJson, null: false

      def resolve
        status_hash(object)
      end

      private

      def status_hash(host)
        PowerManager::PowerStatus.new(host: object).power_state
      rescue => e
        Foreman::Logging.exception("Failed to fetch power status", e)

        {
          id: object.id,
          statusText: _("Failed to fetch power status: %s") % e,
        }
      end
    end
  end
end
