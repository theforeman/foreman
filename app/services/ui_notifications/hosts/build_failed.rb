module UINotifications
  module Hosts
    class BuildFailed < BuildBase
      private

      def blueprint_name
        'host_build_failed'
      end
    end
  end
end
