module UINotifications
  module Hosts
    class BuildCompleted < BuildBase
      private

      def blueprint_name
        'host_build_completed'
      end
    end
  end
end
