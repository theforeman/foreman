module Mutations
  module Hosts
    class Create < CreateMutation
      description 'Creates a new host.'
      graphql_name 'CreateHostMutation'

      resource_class Host::Managed

      argument :name, String
      argument :root_pass, String, required: false
      argument :ip, String
      argument :mac, String
      argument :build, Boolean
      argument :enabled, Boolean
      argument :managed, Boolean, required: false
      argument :overwrite, Boolean
      argument :owner_id, ID, loads: Types::UserOrUsergroupUnion
      argument :location_id, ID, loads: Types::Location
      argument :organization_id, ID, loads: Types::Organization
      argument :environment_id, ID, loads: Types::Environment
      argument :architecture_id, ID, loads: Types::Architecture
      argument :domain_id, ID, loads: Types::Domain
      argument :operatingsystem_id, ID, loads: Types::Operatingsystem
      argument :medium_id, ID, loads: Types::Medium
      argument :ptable_id, ID, loads: Types::Ptable
      argument :subnet_id, ID, loads: Types::Subnet
      argument :compute_resource_id, ID, loads: Types::ComputeResource
      argument :compute_profile_id, ID, loads: Types::ComputeProfile
      argument :hostgroup_id, ID, loads: Types::Hostgroup
      argument :puppet_proxy_id, ID, loads: Types::SmartProxy
      argument :puppet_ca_proxy_id, ID, loads: Types::SmartProxy
      argument :compute_attributes, Types::RawJson, required: false
      argument :interfaces_attributes, [Types::InterfaceAttributesInput], required: false

      field :host, Types::Host, 'The new host.', null: true

      private

      def initialize_object(params)
        host = resource_class.new(host_attributes(params.deep_symbolize_keys))
        host.managed = true if params && params[:managed].nil?

        apply_compute_profile(host)
        host.suggest_default_pxe_loader if params && params[:pxe_loader].nil?
        host
      end

      def apply_compute_profile(host)
        host.apply_compute_profile(InterfaceMerge.new(merge_compute_attributes: true))
        host.apply_compute_profile(ComputeAttributeMerge.new)
      end

      def host_attributes(params)
        return {} if params.nil?

        params[:interfaces_attributes] = params[:interfaces_attributes].map(&:to_h) if params[:interfaces_attributes]
        params = params.deep_clone
        parse_volumes_attributes(params)

        params
      end

      def parse_volumes_attributes(params)
        return unless params[:compute_attributes] && params[:compute_attributes][:volumes_attributes]
        params[:compute_attributes][:volumes_attributes] =
          params[:compute_attributes][:volumes_attributes].map.with_index { |v, i| [i.to_s, v] }.to_h
      end
    end
  end
end
