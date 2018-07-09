module Api::V2::TaxonomiesController
  extend ActiveSupport::Concern

  included do
    include ParameterAttributes

    before_action :rename_config_template, :only => %w{update create}
    before_action :find_optional_nested_object
    before_action :find_taxonomy, :only => %w(show update destroy settings
                                              domain_ids subnet_ids hostgroup_ids config_template_ids ptable_ids compute_resource_ids
                                              medium_ids smart_proxy_ids environment_ids user_ids organization_ids realm_ids)
    before_action :params_match_database, :only => %w(create update)
    before_action :process_parameter_attributes, :only => %w(update)
  end

  extend Apipie::DSL::Concern

  def_param_group :resource do
    param :resource, Hash, :required => true, :action_aware => true do
      param :name, String, :required => true
      param :description, String, :required => false
      param :user_ids, Array, N_("User IDs"), :required => false
      param :smart_proxy_ids, Array, N_("Smart proxy IDs"), :required => false
      param :compute_resource_ids, Array, N_("Compute resource IDs"), :required => false
      param :medium_ids, Array, N_("Medium IDs"), :required => false
      param :config_template_ids, Array, N_("Provisioning template IDs"), :required => false # FIXME: deprecated
      param :ptable_ids, Array, N_("Partition template IDs"), :required => false
      param :provisioning_template_ids, Array, N_("Provisioning template IDs"), :required => false
      param :domain_ids, Array, N_("Domain IDs"), :required => false
      param :realm_ids, Array, N_("Realm IDs"), :required => false
      param :hostgroup_ids, Array, N_("Host group IDs"), :required => false
      param :environment_ids, Array, N_("Environment IDs"), :required => false
      param :subnet_ids, Array, N_("Subnet IDs"), :required => false
      param :parent_id, :number, :desc => N_('Parent ID'), :required => false
      param :ignore_types, Array, N_("List of resources types that will be automatically associated"), :required => false
    end
  end

  api :GET, '/:resource_id', N_('List all :resource_id')
  param_group :search_and_pagination, ::Api::V2::BaseController
  def index
    taxonomy_scope = if @nested_obj
                       taxonomy_class.where(:id => @nested_obj.send("#{taxonomy_single}_ids"))
                     else
                       taxonomy_class
                     end
    @taxonomies = taxonomy_scope.send("my_#{taxonomies_plural}").search_for(*search_options).paginate(paginate_options)
    @total = taxonomy_scope.send("my_#{taxonomies_plural}").count
    instance_variable_set("@#{taxonomies_plural}", @taxonomies)

    @render_template ||= 'api/v2/taxonomies/index'
    render @render_template
  end

  api :GET, '/:resource_id/:id', N_('Show :a_resource')
  param :show_hidden_parameters, :bool, :desc => N_("Display hidden parameter values")
  param :id, :identifier, :required => true
  def show
    @render_template ||= 'api/v2/taxonomies/show'
    render @render_template
  end

  api :POST, '/:resource_id', N_('Create :a_resource')
  param_group :resource, :as => :create
  def create
    @taxonomy = taxonomy_class.new(resource_params)
    instance_variable_set("@#{taxonomy_single}", @taxonomy)
    process_response @taxonomy.save
  end

  api :PUT, '/:resource_id/:id', N_('Update :a_resource')
  param_group :resource
  param :id, :identifier, :required => true
  def update
    # NOTE - if not ! and invalid, the error is undefined method `permission_failed?' for #<Location:0x7fe38c1d3ec8> (NoMethodError)
    # removed process_response & added explicit render 'api/v2/taxonomies/update'.  Otherwise, *_ids are not returned

    process_response @taxonomy.update(resource_params)
  end

  api :DELETE, '/:resource_id/:id', N_('Delete :a_resource')
  param :id, :identifier, :required => true
  def destroy
    process_response @taxonomy.destroy
  rescue Ancestry::AncestryException
    render :json => {:error => {:message => (_('Cannot delete %{current} because it has nested %{sti_name}.') % { :current => @taxonomy.title, :sti_name => @taxonomy.sti_name }) } }
  end

  # overriding public FindCommon#resource_scope to scope only to user's taxonomies
  def resource_scope(*args)
    @resource_scope ||= scope_for(resource_class, args).send("my_#{taxonomies_plural}")
  end

  private

  def rename_config_template
    if params[taxonomy_single] && params[taxonomy_single][:config_template_ids].present?
      params[taxonomy_single][:provisioning_template_ids] = params[taxonomy_single].delete(:config_template_ids)
      Foreman::Deprecation.api_deprecation_warning('Config templates were renamed to provisioning templates')
    end
  end

  def params_match_database
    # change params[:select_all_types] to params[:ignore_types] to match database
    if params[taxonomy_single].try(:[], :select_all_types)
      params[taxonomy_single][:ignore_types] = params[taxonomy_single][:select_all_types]
      params[taxonomy_single]                = params[taxonomy_single].reject { |k, v| k == "select_all_types" }
      params[taxonomy_single]
    end
  end

  def taxonomy_id
    "#{taxonomy_single}_id".to_sym
  end

  def taxonomy_single
    controller_name.singularize
  end

  def taxonomies_plural
    controller_name
  end

  def taxonomy_class
    controller_name.classify.constantize
  end

  def find_taxonomy
    @taxonomy = find_resource
  end

  def allowed_nested_id
    %w(domain_id compute_resource_id subnet_id environment_id hostgroup_id smart_proxy_id user_id medium_id organization_id location_id filter_id)
  end

  def resource_params
    public_send("#{taxonomy_single}_params".to_sym)
  end
end
