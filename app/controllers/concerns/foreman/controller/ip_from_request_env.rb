module Foreman
  module Controller
    module IpFromRequestEnv
      extend ActiveSupport::Concern

      protected

      def ip_from_request_env
        ip = request.env['REMOTE_ADDR']

        # check if someone is asking on behalf of another system (load balancer etc)
        ip = request.env['HTTP_X_FORWARDED_FOR'] if request.env['HTTP_X_FORWARDED_FOR'].present? && (ip =~ Regexp.new(Setting[:remote_addr]))

        ip
      end
    end
  end
end
