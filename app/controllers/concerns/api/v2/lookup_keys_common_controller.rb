module Api::V2::LookupKeysCommonController
  extend ActiveSupport::Concern

    included do
      before_filter :find_environment, :if => :environment_id?
      before_filter :find_puppetclass, :if => :puppetclass_id?
      before_filter :find_system,  :if => :system_id?
      before_filter :find_system_group,  :if => :system_group_id?

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

    def system_id?
      params.keys.include?('system_id')
    end

    def system_group_id?
      params.keys.include?('system_group_id')
    end

    def smart_variable_id?
      params.keys.include?('smart_variable_id') || controller_name.match(/smart_variables/)
    end

    def smart_class_parameter_id?
      params.keys.include?('smart_class_parameter_id') || controller_name.match(/smart_class_parameters/)
    end

    def find_puppetclass
      @puppetclass   = Puppetclass.find_by_id(params['puppetclass_id'].to_i) if params['puppetclass_id'].to_i > 0
      @puppetclass ||= Puppetclass.find_by_name(params['puppetclass_id'])
      @puppetclass
    end

    def find_environment
      @environment   = Environment.find_by_id(params['environment_id'].to_i) if params['environment_id'].to_i > 0
      @environment ||= Environment.find_by_name(params['environment_id'])
      @environment
    end

    def find_system
      @system   = System::Base.find_by_id(params['system_id'].to_i) if params['system_id'].to_i > 0
      @system ||= System::Base.find_by_name(params['system_id'])
      @system
    end

    def find_system_group
      @system_group   = SystemGroup.find_by_id(params['system_group_id'].to_i) if params['system_group_id'].to_i > 0
      @system_group ||= SystemGroup.find_by_name(params['system_group_id'])
      @system_group
    end

    def find_smart_variable
      id = params.keys.include?('smart_variable_id') ? params['smart_variable_id'] : params['id']
      @smart_variable   = LookupKey.smart_variables.find_by_id(id.to_i) if id.to_i > 0
      @smart_variable ||= (puppet_cond = { :puppetclass_id => @puppetclass.id } if @puppetclass
                           LookupKey.smart_variables.where(puppet_cond).find_by_key(id)
                          )
      @smart_variable
    end

    def find_smart_variables
      @smart_variables   = LookupKey.smart_variables.search_for(*search_options).paginate(paginate_options) unless (@puppetclass || @system || @system_group)
      @smart_variables ||= if @puppetclass
                              LookupKey.global_parameters_for_class(@puppetclass.id).search_for(*search_options).paginate(paginate_options)
                           elsif @system || @system_group
                              puppetclass_ids  = (@system || @system_group).all_puppetclasses.map(&:id)
                              LookupKey.global_parameters_for_class(puppetclass_ids).search_for(*search_options).paginate(paginate_options)
                           end
      @smart_variables
    end


    def find_smart_class_parameter
      id = params.keys.include?('smart_class_parameter_id') ? params['smart_class_parameter_id'] : params['id']
      @smart_class_parameter = LookupKey.smart_class_parameters.find_by_id(id.to_i) if id.to_i > 0
      @smart_class_parameter ||= (puppet_cond = { 'environment_classes.puppetclass_id'=> @puppetclass.id } if @puppetclass
                                  env_cond = { 'environment_classes.environment_id' => @environment.id } if @environment
                                  LookupKey.smart_class_parameters.where(puppet_cond).where(env_cond).where(:key => id).first
                                 )
      @smart_class_parameter
    end

    def find_smart_class_parameters
      @smart_class_parameters   = LookupKey.smart_class_parameters.search_for(*search_options).paginate(paginate_options) unless (@puppetclass || @environment || @system || @system_group)

      @smart_class_parameters ||= if @puppetclass && @environment
                                    LookupKey.smart_class_parameters_for_class(@puppetclass.id, @environment.id)
                                  elsif @puppetclass && !@environment
                                    environment_ids = @puppetclass.environment_classes.pluck(:environment_id).uniq
                                    LookupKey.smart_class_parameters_for_class(@puppetclass.id, environment_ids).search_for(*search_options).paginate(paginate_options)
                                  elsif !@puppetclass && @environment
                                    puppetclass_ids = @environment.environment_classes.pluck(:puppetclass_id).uniq
                                    LookupKey.smart_class_parameters_for_class(puppetclass_ids, @environment.id).search_for(*search_options).paginate(paginate_options)
                                  elsif @system || @system_group
                                    puppetclass_ids = (@system || @system_group).all_puppetclasses.map(&:id)
                                    environment_id  = (@system || @system_group).environment_id
                                    LookupKey.parameters_for_class(puppetclass_ids, environment_id).search_for(*search_options).paginate(paginate_options)
                                  end
      @smart_class_parameters
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
        msg = "#{obj} not found by id '#{id}'"
        render :json => {:message => msg}, :status => :not_found and return false
      end
    end

end
