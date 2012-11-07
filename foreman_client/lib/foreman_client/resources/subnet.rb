module ForemanClient
  module Resources
    class Subnet < Apipie::Client::Base
      def self.doc
        @doc ||= ForemanClient.doc['resources']["subnets"]
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["search", "order"]
      #
      # @param [Hash] headers additional http headers
      def index(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/subnets", params
        call(:"get", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: {"subnet"=>["name", "network", "mask", "gateway", "dns_primary", "dns_secondary", "from", "to", "vlanid", "domain_ids", "dhcp_id", "tftp_id", "dns_id"]}
      #
      # @param [Hash] headers additional http headers
      def create(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/subnets", params
        call(:"post", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: {"subnet"=>["name", "network", "mask", "gateway", "dns_primary", "dns_secondary", "from", "to", "vlanid", "domain_ids", "dhcp_id", "tftp_id", "dns_id"], "id"=>nil}
      #
      # @param [Hash] headers additional http headers
      def update(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/subnets/:id", params
        call(:"put", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["id"]
      #
      # @param [Hash] headers additional http headers
      def destroy(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/subnets/:id", params
        call(:"delete", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["subnet_id", "host_mac"]
      #
      # @param [Hash] headers additional http headers
      def freeip(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/subnets/freeip", params
        call(:"post", url, params, headers)
      end

    end
  end
end
