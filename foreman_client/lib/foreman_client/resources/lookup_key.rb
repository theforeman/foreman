module ForemanClient
  module Resources
    class LookupKey < Apipie::Client::Base
      def self.doc
        @doc ||= ForemanClient.doc['resources']["lookup_keys"]
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["search", "order"]
      #
      # @param [Hash] headers additional http headers
      def index(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/lookup_keys", params
        call(:"get", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["id"]
      #
      # @param [Hash] headers additional http headers
      def show(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/lookup_keys/:id", params
        call(:"get", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: {"lookup_key"=>["key", "puppetclass_id", "default_value", "path", "description", "lookup_values_count"]}
      #
      # @param [Hash] headers additional http headers
      def create(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/lookup_keys", params
        call(:"post", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: {"id"=>nil, "lookup_key"=>["key", "puppetclass_id", "default_value", "path", "description", "lookup_values_count"]}
      #
      # @param [Hash] headers additional http headers
      def update(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/lookup_keys/:id", params
        call(:"put", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["id"]
      #
      # @param [Hash] headers additional http headers
      def destroy(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/lookup_keys/:id", params
        call(:"delete", url, params, headers)
      end

    end
  end
end
