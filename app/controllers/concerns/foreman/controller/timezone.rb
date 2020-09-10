module Foreman
  module Controller
    module Timezone
      extend ActiveSupport::Concern

      def set_timezone
        default_timezone = Time.zone
        client_timezone  = User.current.try(:timezone) || cookies[:timezone]
        Time.zone        = client_timezone if client_timezone.present?
        yield
      ensure
        # Reset timezone for the next thread
        Time.zone = default_timezone
      end
    end
  end
end
