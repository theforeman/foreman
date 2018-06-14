module Api::V2::LookupKeysCommonController
  extend ActiveSupport::Concern

  included do
    before_action :find_environment, :if => :environment_id?
    before_action :find_puppetclass, :if => :puppetclass_id?
    before_action :find_host, :if => :host_id?
    before_action :find_hostgroup, :if => :hostgroup_id?

    before_action :find_smart_class_parameters, :if => :smart_class_parameter_id?
    before_action :find_smart_class_parameter, :if => :smart_class_parameter_id?

    before_action :find_smart_variables, :if => :smart_variable_id?
    before_action :find_smart_variable, :if => :smart_variable_id?

    before_action :find_smarts
    before_action :find_smart

    before_action :return_if_smart_mismatch, :only => [:show, :update, :destroy]

    before_action :cast_default_value, :only => [:create, :update]
  end

  def smart_variable_id?
    params.key?('smart_variable_id') || controller_name.match(/smart_variables/)
  end

  def smart_class_parameter_id?
    params.key?('smart_class_parameter_id') || controller_name.match(/smart_class_parameters/)
  end

  [Puppetclass, Environment, Host::Base, Hostgroup].each do |model|
    model_string = model.to_s.split('::').first.downcase

    define_method("#{model_string}_id?") do
      params.key?("#{model_string}_id")
    end

    define_method("find_#{model_string}") do
      scope = model.authorized(:"view_#{model_string.pluralize}")
      begin
        instance_variable_set("@#{model_string}",
                              resource_finder(scope, params["#{model_string}_id"]))
      rescue ActiveRecord::RecordNotFound
        model_not_found(model_string)
      end
    end
  end

  def find_smart_variable
    id = params.key?('smart_variable_id') ? params['smart_variable_id'] : params['id']
    @smart_variable   = VariableLookupKey.authorized(:view_external_variables).smart_variables.find_by_id(id.to_i) if id.to_i > 0
    @smart_variable ||= begin
                          puppet_cond = { :puppetclass_id => @puppetclass.id } if @puppetclass
                          VariableLookupKey.authorized(:view_external_variables).smart_variables.where(puppet_cond).find_by_key(id.to_s)
                        end
    @smart_variable
  end

  def find_smart_variables
    @smart_variables = smart_variables_resource_scope.search_for(*search_options).paginate(paginate_options)
  end

  def smart_variables_resource_scope
    return VariableLookupKey.authorized(:view_external_variables).smart_variables unless (@puppetclass || @host || @hostgroup)
    puppetclass_ids   = @puppetclass.id if @puppetclass
    puppetclass_ids ||= @hostgroup.all_puppetclasses.map(&:id) if @hostgroup
    puppetclass_ids ||= @host.all_puppetclasses.map(&:id) if @host
    VariableLookupKey.authorized(:view_external_variables).global_parameters_for_class(puppetclass_ids)
  end

  def find_smart_class_parameter
    id = params.key?('smart_class_parameter_id') ? params['smart_class_parameter_id'] : params['id']
    @smart_class_parameter = PuppetclassLookupKey.authorized(:view_external_parameters).smart_class_parameters.find_by_id(id.to_i) if id.to_i > 0
    @smart_class_parameter ||= begin
                                 puppet_cond = { 'environment_classes.puppetclass_id' => @puppetclass.id } if @puppetclass
                                 env_cond = { 'environment_classes.environment_id' => @environment.id } if @environment
                                 PuppetclassLookupKey.authorized(:view_external_parameters).smart_class_parameters.where(puppet_cond).where(env_cond).where(:key => id).first
                               end
    @smart_class_parameter
  end

  def find_smart_class_parameters
    @smart_class_parameters = smart_class_parameters_resource_scope.search_for(*search_options).paginate(paginate_options)
  end

  def smart_class_parameters_resource_scope
    base = PuppetclassLookupKey.authorized(:view_external_parameters)
    params = if !@puppetclass && !@environment && !@host && !@hostgroup
               base.smart_class_parameters
             elsif @puppetclass && @environment
               base.smart_class_parameters_for_class(@puppetclass.id, @environment.id)
             elsif @puppetclass && !@environment
               environment_ids = @puppetclass.environment_classes.pluck(:environment_id).uniq
               base.smart_class_parameters_for_class(@puppetclass.id, environment_ids)
             elsif !@puppetclass && @environment
               puppetclass_ids = @environment.environment_classes.pluck(:puppetclass_id).uniq
               base.smart_class_parameters_for_class(puppetclass_ids, @environment.id)
             elsif @host || @hostgroup
               puppetclass_ids = (@host || @hostgroup).all_puppetclasses.map(&:id)
               environment_id  = (@host || @hostgroup).environment_id
               # scope :parameters_for_class uses .override
               base.parameters_for_class(puppetclass_ids, environment_id)
             end
    params.distinct
  end

  def find_smarts
    @smarts   = @smart_variables
    @smarts ||= @smart_class_parameters
    @smarts
  end

  def find_smart
    @smart   = @smart_variable
    @smart ||= @smart_class_parameter
    @smart
  end

  def return_if_smart_mismatch
    if (@smarts && @smart && !@smarts.find_by_id(@smart.id)) || (@smarts && !@smart)
      obj = smart_variable_id? ? "Smart variable" : "Smart class parameter"
      id = if smart_variable_id?
             params.key?('smart_variable_id') ? params['smart_variable_id'] : params['id']
           else
             params.key?('smart_class_parameter_id') ? params['smart_variable_id'] : params['id']
           end
      not_found "#{obj} not found by id '#{id}'"
    end
  end

  def cast_default_value
    obj = smart_variable_id? ? "smart_variable" : "smart_class_parameter"

    cast_value(obj, :default_value)
  end

  def cast_value(obj = :override_value, value = :value)
    return unless params[obj]&.key?(value)
    param_value = params[obj][value]
    return if param_value.is_a?(Hash)
    params[obj][value] = param_value.to_s
  end

  private

  def model_not_found(model)
    error_message = (
      _("%{model} with id '%{id}' was not found") %
      { :id => params["#{model}_id"], :model => model.capitalize })
    not_found(:error => { :message => error_message })
  end
end
