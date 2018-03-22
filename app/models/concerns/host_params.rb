module HostParams
  extend ActiveSupport::Concern

  included do
    has_many :host_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :host
    has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "HostParameter"
    accepts_nested_attributes_for :host_parameters, :allow_destroy => true
    include ParameterValidators

    def params
      host_params.update(HostInfoProviders::PuppetInfo.new(self).smart_variables)
    end

    def clear_host_parameters_cache!
      @cached_host_params_rendered = nil
      @cached_host_params_hash = nil
    end

    def inherited_params_hash
      params_to_hash(host_inherited_params_objects)
    end

    def non_inherited_params_hash
      params_to_hash(host_parameters.authorized(:view_params))
    end

    def params_to_hash(params)
      params.each_with_object({}) do |param, hash|
        source = param.associated_type
        options = {:value => param.value,
                   :source => source,
                   :safe_value => param.safe_value }
        options[:source_name] = param.associated_label if source != 'global'
        hash[param.name] = options
      end
    end

    def host_params_renderer
      @host_params_renderer ||= ParameterSafeRender.new(self)
    end

    def host_params_hash
      @cached_host_params_hash ||= inherited_params_hash.merge(non_inherited_params_hash)
    end

    def host_param(name)
      if @cached_host_params_rendered
        @cached_host_params_rendered[name]
      else
        host_params_renderer.render(host_params_hash.fetch(name, {})[:value])
      end
    end

    def host_params
      return @cached_host_params_rendered if @cached_host_params_rendered
      key_value_hash = host_params_hash.each_with_object({}) do |(key, value), hash|
        hash[key] = value[:value]
      end
      @cached_host_params_rendered = host_params_renderer.render(key_value_hash)
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
