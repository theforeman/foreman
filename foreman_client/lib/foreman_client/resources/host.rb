module ForemanClient
  module Resources
    class Host < Apipie::Client::Base
      def self.doc
        @doc ||= ForemanClient.doc['resources']["hosts"]
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["search", "order"]
      #
      # @param [Hash] headers additional http headers
      def index(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hosts", params
        call(:"get", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["id"]
      #
      # @param [Hash] headers additional http headers
      def show(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hosts/:id", params
        call(:"get", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: {"host"=>["name", "environment_id", "ip", "mac", "architecture_id", "domain_id", "puppet_proxy_id", "operatingsystem_id", "medium_id", "ptable_id", "subnet_id", "sp_subnet_id", "model_id_id", "hostgroup_id", "owner_id", "puppet_ca_proxy_id", "image_id", "host_parameters_attributes"]}
      #
      # @param [Hash] headers additional http headers
      def create(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hosts", params
        call(:"post", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: {"id"=>nil, "host"=>["name", "environment_id", "ip", "mac", "architecture_id", "domain_id", "puppet_proxy_id", "operatingsystem_id", "medium_id", "ptable_id", "subnet_id", "sp_subnet_id", "model_id_id", "hostgroup_id", "owner_id", "puppet_ca_proxy_id", "image_id", "host_parameters_attributes"]}
      #
      # @param [Hash] headers additional http headers
      def update(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hosts/:id", params
        call(:"put", url, params, headers)
      end

      # @param [Hash] params a hash of params to be passed to the service
      # allowed keys are: ["id"]
      #
      # @param [Hash] headers additional http headers
      def destroy(params = { }, headers = { })
        check_params params, :allowed => true, :method => __method__
        url, params = fill_params_in_url "/api/hosts/:id", params
        call(:"delete", url, params, headers)
      end

    end
  end
end
