module HostParams
  extend ActiveSupport::Concern

  included do
    include ParameterValidators
    attr_reader :cached_host_params, :host_parameters_hash

    def params
      host_params.update(lookup_keys_params)
    end

    def clear_host_parameters_cache!
      @cached_host_params = nil
      @host_parameters_hash = nil
    end

    def host_params_hash
      return @host_parameters_hash unless @host_parameters_hash.blank?
      @host_parameters_hash = Classification::NonPuppetParam.new(:host=>self).values_hash
    end

    def host_params
      return @cached_host_params unless @cached_host_params.blank?

      hp = {}
      host_params_hash.each  do |param|
        param_hash = param.last
        key = param_hash.keys[0]
        value = param_hash[key][:value]
        hp.update Hash[key => value]
      end
      @cached_host_params = hp
    end

    def host_params_objects(params_hash = nil)
      params_hash ||= host_params_hash
      lookup_keys = LookupKey.where(:id => params_hash.keys).authorized
      values = []
      params_hash.each do |key, param|
        value = param.values[0]
        value_element = value[:element]
        key = lookup_keys.detect{|x| x.id == key}
        if value_element == 'Default value'
          values << key
        else
          values << key.lookup_values.detect{ |x| x.match = "#{value_element}=#{value[:element_name]}"} if key.present?
        end
      end
      values
    end
  end
end
