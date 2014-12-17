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

  def puppetclass_id?
    params.keys.include?('puppetclass_id')
  end

  def environment_id?
    params.keys.include?('environment_id')
  end

  def host_id?
    params.keys.include?('host_id')
  end

  def hostgroup_id?
    params.keys.include?('hostgroup_id')
  end

  def smart_variable_id?
    params.keys.include?('smart_variable_id') || controller_name.match(/smart_variables/)
  end

  def smart_class_parameter_id?
    params.keys.include?('smart_class_parameter_id') || controller_name.match(/smart_class_parameters/)
  end

  def find_puppetclass
    @puppetclass = Puppetclass.authorized(:view_puppetclasses).find(params['puppetclass_id'])
  rescue ActiveRecord::RecordNotFound
    not_found({ :error => { :message => (_("Puppet class with id '%{id}' was not found") % { :id => params['puppetclass_id'] }) } })
  end

  def find_environment
    @environment = Environment.authorized(:view_environments).find(params['environment_id'])
  rescue ActiveRecord::RecordNotFound
    not_found({ :error => { :message => (_("Environment with id '%{id}' was not found") % { :id => params['environment_id'] }) } })
  end

  def find_host
    @host = Host::Base.authorized(:view_hosts).friendly.find(params['host_id'])
  rescue ActiveRecord::RecordNotFound
    not_found({ :error => { :message => (_("Host with id '%{id}' was not found") % { :id => params['host_id'] }) } })
  end

  def find_hostgroup
    @hostgroup = Hostgroup.authorized(:view_hostgroups).find(params['hostgroup_id'])
  rescue ActiveRecord::RecordNotFound
    not_found({ :error => { :message => (_("Hostgroup with id '%{id}' was not found") % { :id => params['hostgroup_id'] }) } })
  end

  def find_smart_variable
    id = params.keys.include?('smart_variable_id') ? params['smart_variable_id'] : params['id']
    @smart_variable   = LookupKey.authorized(:view_external_variables).smart_variables.find_by_id(id.to_i) if id.to_i > 0
    @smart_variable ||= (puppet_cond = { :puppetclass_id => @puppetclass.id } if @puppetclass
                         LookupKey.authorized(:view_external_variables).smart_variables.where(puppet_cond).find_by_key(id)
                        )
    @smart_variable
  end

  def find_smart_variables
    @smart_variables = smart_variables_resource_scope.search_for(*search_options).paginate(paginate_options)
  end

  def smart_variables_resource_scope
    return LookupKey.authorized(:view_external_variables).smart_variables unless (@puppetclass || @host || @hostgroup)
    puppetclass_ids   = @puppetclass.id if @puppetclass
    puppetclass_ids ||= @hostgroup.all_puppetclasses.map(&:id) if @hostgroup
    puppetclass_ids ||= @host.all_puppetclasses.map(&:id) if @host
    LookupKey.authorized(:view_external_variables).global_parameters_for_class(puppetclass_ids)
  end

  def find_smart_class_parameter
    id = params.keys.include?('smart_class_parameter_id') ? params['smart_class_parameter_id'] : params['id']
    @smart_class_parameter = LookupKey.authorized(:view_external_variables).smart_class_parameters.find_by_id(id.to_i) if id.to_i > 0
    @smart_class_parameter ||= (puppet_cond = { 'environment_classes.puppetclass_id'=> @puppetclass.id } if @puppetclass
                                env_cond = { 'environment_classes.environment_id' => @environment.id } if @environment
                                LookupKey.authorized(:view_external_variables).smart_class_parameters.where(puppet_cond).where(env_cond).where(:key => id).first
                               )
    @smart_class_parameter
  end

  def find_smart_class_parameters
    @smart_class_parameters = smart_class_parameters_resource_scope.search_for(*search_options).paginate(paginate_options)
  end

  def smart_class_parameters_resource_scope
    base = LookupKey.authorized(:view_external_variables)
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
end
