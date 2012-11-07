module ForemanClient
  module Resources
    class Home < Apipie::Client::Base
      def self.doc
        @doc ||= ForemanClient.doc['resources']["home"]
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: []
      #
      # @param [Hash] headers additional http headers
      def index(params = { }, headers = { })
        check_params params, :allowed => false, :method => __method__
        url, params = fill_params_in_url "/api", params
        call(:"get", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: []
      #
      # @param [Hash] headers additional http headers
      def status(params = { }, headers = { })
        check_params params, :allowed => false, :method => __method__
        url, params = fill_params_in_url "/api/status", params
        call(:"get", url, params, headers)
      end

    end
  end
end
