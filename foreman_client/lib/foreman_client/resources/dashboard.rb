module ForemanClient
  module Resources
    class Dashboard < Apipie::Client::Base
      def self.doc
        @doc ||= ForemanClient.doc['resources']["dashboard"]
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["search"]
      #
      # @param [Hash] headers additional http headers
      def index(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/dashboard", params
        call(:"get", url, params, headers)
      end

    end
  end
end
