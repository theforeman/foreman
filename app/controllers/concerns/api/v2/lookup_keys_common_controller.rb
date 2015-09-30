module Api::V2::LookupKeysCommonController
  extend ActiveSupport::Concern

  included do
    before_filter :find_environment, :if => :environment_id?
    before_filter :find_puppetclass, :if => :puppetclass_id?
    before_filter :find_host,  :if => :host_id?
    before_filter :find_hostgroup,  :if => :hostgroup_id?

    before_filter :find_smart_class_parameters, :if => :smart_class_parameter_id?
    before_filter :find_smart_class_parameter, :if => :smart_class_parameter_id?

    before_filter :find_smart_variables, :if => :smart_variable_id?
    before_filter :find_smart_variable, :if => :smart_variable_id?

    before_filter :find_smarts
    before_filter :find_smart

    before_filter :return_if_smart_mismatch, :only => [:show, :update, :destroy]
  end

  def smart_variable_id?
    params.keys.include?('smart_variable_id') || controller_name.match(/smart_variables/)
  end

  def smart_class_parameter_id?
    params.keys.include?('smart_class_parameter_id') || controller_name.match(/smart_class_parameters/)
  end

  [Puppetclass, Environment, Host::Base, Hostgroup].each do |model|
    model_string = model.to_s.split('::').first.downcase

    define_method("#{model_string}_id?") do
      params.keys.include?("#{model_string}_id")
    end

    define_method("find_#{model_string}") do
      begin
        instance_variable_set("@#{model_string}",
                              model.authorized(:"view_#{model_string.pluralize}").
                                    from_param(params["#{model_string}_id"]))

        # Handle the case where .from_param will not raise any exception.
        # If the model is parameterized by name, it will use find_by_name and
        # a failed search will just return nil.
        if instance_variable_get("@#{model_string}").nil? &&
             model.included_modules.include?(Parameterizable::ByName)
          model_not_found(model_string)
        end
      rescue ActiveRecord::RecordNotFound
        model_not_found(model_string)
      end
    end
  end

  def find_smart_variable
    id = params.keys.include?('smart_variable_id') ? params['smart_variable_id'] : params['id']
    @smart_variable   = VariableLookupKey.authorized(:view_external_variables).smart_variables.find_by_id(id.to_i) if id.to_i > 0
    @smart_variable ||= (puppet_cond = { :puppetclass_id => @puppetclass.id } if @puppetclass
                         VariableLookupKey.authorized(:view_external_variables).smart_variables.where(puppet_cond).find_by_key(id)
                        )
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
    id = params.keys.include?('smart_class_parameter_id') ? params['smart_class_parameter_id'] : params['id']
    @smart_class_parameter = PuppetclassLookupKey.authorized(:view_external_variables).smart_class_parameters.find_by_id(id.to_i) if id.to_i > 0
    @smart_class_parameter ||= (puppet_cond = { 'environment_classes.puppetclass_id'=> @puppetclass.id } if @puppetclass
                                env_cond = { 'environment_classes.environment_id' => @environment.id } if @environment
                                PuppetclassLookupKey.authorized(:view_external_variables).smart_class_parameters.where(puppet_cond).where(env_cond).where(:key => id).first
                               )
    @smart_class_parameter
  end

  def find_smart_class_parameters
    @smart_class_parameters = smart_class_parameters_resource_scope.search_for(*search_options).paginate(paginate_options)
  end

  def smart_class_parameters_resource_scope
    base = PuppetclassLookupKey.authorized(:view_external_variables)
    return base.smart_class_parameters unless (@puppetclass || @environment || @host || @hostgroup)
    if @puppetclass && @environment
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
             params.keys.include?('smart_variable_id') ? params['smart_variable_id'] : params['id']
           else
             params.keys.include?('smart_class_parameter_id') ? params['smart_variable_id'] : params['id']
           end
      not_found "#{obj} not found by id '#{id}'"
    end
  end

  private

  def model_not_found(model_name)
    not_found(:error => { :message => (_("#{model_name.capitalize} with id '%{id}' was not found") %
                                         { :id => params["#{model_name}_id"] } ) } )
  end
end
