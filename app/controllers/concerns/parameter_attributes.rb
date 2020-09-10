module ParameterAttributes
  extend ActiveSupport::Concern

  def process_parameter_attributes
    model_params = params[parameter_method_mapping]
    return unless model_params
    parameter_params = model_params["#{parameter_class_mapping}_parameters_attributes"]
    return unless parameter_params
    # parameters may be either Array or indexed Hash
    parameter_params = parameter_params.values unless parameter_params.kind_of?(Array)

    param_names = parameter_params.map { |hash| hash[:name] }

    process_update obj_names, param_names, parameter_params, param_klass
    process_destroy obj_names, param_names, parameter_params, param_klass
  end

  private

  def param_klass
    "#{parameter_class_mapping.to_s.capitalize}Parameter".constantize
  end

  def obj_names
    param_klass.where(:reference_id => instance_variable_get("@#{parameter_method_mapping}").id).map(&:name)
  end

  def process_destroy(obj_names, param_names, parameter_params, param_klass)
    delete_names = obj_names - param_names
    delete_names.each do |delete_name|
      parameter_params << { "id" => fetch_parameter(param_klass, delete_name).id, "_destroy" => true }
    end
  end

  def process_update(obj_names, param_names, parameter_params, param_klass)
    update_names = param_names & obj_names
    parameter_params.map! do |parameter|
      if update_names.include? parameter[:name]
        parameter.tap { |hash| hash[:id] = fetch_parameter(param_klass, parameter[:name]).id }
      else
        parameter
      end
    end
  end

  def fetch_parameter(param_klass, name)
    param_klass.find_by(:name => name, :reference_id => instance_variable_get("@#{parameter_method_mapping}").id)
  end

  def parameter_method_mapping
    case controller_name.classify
      when "Operatingsystem" then :operatingsystem
      when "Hostgroup"       then :hostgroup
      else parameter_common_mapping
    end
  end

  def parameter_class_mapping
    case controller_name.classify
      when "Operatingsystem" then :os
      when "Hostgroup"       then :group
      else parameter_common_mapping
    end
  end

  def parameter_common_mapping
    case controller_name.classify
      when "Host"            then :host
      when "Domain"          then :domain
      when "Organization"    then :organization
      when "Location"        then :location
      when "Subnet"          then :subnet
    end
  end
end
