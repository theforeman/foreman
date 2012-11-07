module ForemanClient
  module Resources
    class Hostgroup < Apipie::Client::Base
      def self.doc
        @doc ||= ForemanClient.doc['resources']["hostgroups"]
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["search", "order"]
      #
      # @param [Hash] headers additional http headers
      def index(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hostgroups", params
        call(:"get", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["id"]
      #
      # @param [Hash] headers additional http headers
      def show(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hostgroups/:id", params
        call(:"get", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: {"hostgroup"=>["name", "environment_id", "operatingsystem_id", "architecture_id", "medium_id", "ptable_id", "puppet_ca_proxy_id", "subnet_id", "domain_id", "puppet_proxy_id"]}
      #
      # @param [Hash] headers additional http headers
      def create(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hostgroups", params
        call(:"post", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: {"hostgroup"=>["name", "environment_id", "operatingsystem_id", "architecture_id", "medium_id", "ptable_id", "puppet_ca_proxy_id", "subnet_id", "domain_id", "puppet_proxy_id"], "id"=>nil}
      #
      # @param [Hash] headers additional http headers
      def update(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hostgroups/:id", params
        call(:"put", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["id"]
      #
      # @param [Hash] headers additional http headers
      def destroy(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hostgroups/:id", params
        call(:"delete", url, params, headers)
      end

    end
  end
end
