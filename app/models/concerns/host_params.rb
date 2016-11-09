module HostParams
  extend ActiveSupport::Concern

  included do
    has_many :host_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :host
    has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "HostParameter"
    accepts_nested_attributes_for :host_parameters, :allow_destroy => true
    include ParameterValidators
    attr_reader :cached_host_params

    def params
      Foreman::Deprecation.renderer_deprecation('1.17', __method__, 'host_param') unless caller.first.match(/renderer\.rb.*host_param/)
      host_params.update(lookup_keys_params)
    end

    def clear_host_parameters_cache!
      @cached_host_params = nil
    end

    def host_inherited_params(include_source = false)
      hp = {}
      params = host_inherited_params_objects
      params.each do |param|
        source = param.associated_type
        options = {:value => param.value,
                   :source => source,
                   :safe_value => param.safe_value }
        if source != 'global'
          options.merge!(:source_name => param.associated_label)
        end
        hp.update(Hash[param.name => include_source ? options : param.value])
      end
      hp
    end

    def host_params
      return cached_host_params unless cached_host_params.blank?
      hp = host_inherited_params
      # and now read host parameters, override if required
      host_parameters.authorized(:view_params).each { |p| hp[p.name] = p.value }
      @cached_host_params = hp
    end

    def host_inherited_params_objects
      params = CommonParameter.all
      if SETTINGS[:organizations_enabled] && organization
        params += extract_params_from_object_ancestors(organization)
      end

      if SETTINGS[:locations_enabled] && location
        params += extract_params_from_object_ancestors(location)
      end

      params += domain.domain_parameters.authorized(:view_params) if domain
      params += subnet.subnet_parameters.authorized(:view_params) if subnet
      params += subnet6.subnet_parameters.authorized(:view_params) if subnet6
      params += operatingsystem.os_parameters.authorized(:view_params) if operatingsystem
      params += extract_params_from_object_ancestors(hostgroup) if hostgroup
      params
    end

    def host_params_objects
      # Host parameters should always be first for the uniq order
      (host_parameters.authorized(:view_params) + host_inherited_params_objects.to_a.reverse!).uniq {|param| param.name}
    end
  end
end
