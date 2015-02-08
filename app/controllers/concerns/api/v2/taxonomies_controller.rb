module Api::V2::TaxonomiesController
  extend ActiveSupport::Concern

  included do
    before_filter :find_optional_nested_object
    before_filter :find_taxonomy, :only => %w(show update destroy settings
                                              domain_ids subnet_ids hostgroup_ids config_template_ids compute_resource_ids
                                              medium_ids smart_proxy_ids environment_ids user_ids organization_ids realm_ids)
    before_filter :params_match_database, :only => %w(create update)
  end

  extend Apipie::DSL::Concern

  def_param_group :resource do
    param :resource, Hash, :required => true, :action_aware => true do
      param :name, String, :required => true
      param :description, String, :required => false
      param :user_ids, Array, N_("User IDs"), :required => false
      param :smart_proxy_ids, Array, N_("Smart proxy IDs"), :required => false
      param :compute_resource_ids, Array, N_("Compute resource IDs"), :required => false
      param :media_ids, Array, N_("Media IDs"), :required => false
      param :config_template_ids, Array, N_("Provisioning template IDs"), :required => false
      param :domain_ids, Array, N_("Domain IDs"), :required => false
      param :realm_ids, Array, N_("Realm IDs"), :required => false
      param :hostgroup_ids, Array, N_("Host group IDs"), :required => false
      param :environment_ids, Array, N_("Environment IDs"), :required => false
      param :subnet_ids, Array, N_("Subnet IDs"), :required => false
    end
  end

  api :GET, '/:resource_id', N_('List all :resource_id')
  param_group :search_and_pagination, ::Api::V2::BaseController
  def index
    if @nested_obj
      @taxonomies = @nested_obj.send(taxonomies_plural).search_for(*search_options).paginate(paginate_options)
      @total = @nested_obj.send(taxonomies_plural).count
    else
      @taxonomies = taxonomy_class.search_for(*search_options).paginate(paginate_options)
      @total = taxonomy_class.count
    end
    instance_variable_set("@#{taxonomies_plural}", @taxonomies)

    @render_template ||= 'api/v2/taxonomies/index'
    render @render_template
  end

  api :GET, '/:resource_id/:id', N_('Show :a_resource')
  def show
    @render_template ||= 'api/v2/taxonomies/show'
    render @render_template
  end

  api :POST, '/:resource_id', N_('Create :a_resource')
  param_group :resource, :as => :create
  def create
    @taxonomy = taxonomy_class.new(params[taxonomy_single.to_sym])
    instance_variable_set("@#{taxonomy_single}", @taxonomy)
    process_response @taxonomy.save
  end

  api :PUT, '/:resource_id/:id', N_('Update :a_resource')
  param_group :resource
  def update
    # NOTE - if not ! and invalid, the error is undefined method `permission_failed?' for #<Location:0x7fe38c1d3ec8> (NoMethodError)
    # removed process_response & added explicit render 'api/v2/taxonomies/update'.  Otherwise, *_ids are not returned

    process_response  @taxonomy.update_attributes(params[taxonomy_single.to_sym])
  end

  api :DELETE, '/:resource_id/:id', N_('Delete :a_resource')
  def destroy
    process_response @taxonomy.destroy
  rescue Ancestry::AncestryException
    render :json => {:error => {:message => (_('Cannot delete %{current} because it has nested %{sti_name}.') % { :current => @taxonomy.title, :sti_name => @taxonomy.sti_name }) } }
  end

  api :POST, "/:resource_id/:res_id/links/users", N_("Add user to :resource")
  api :POST, "/:resource_id/:res_id/links/smart_proxies", N_("Add smart proxy to :resource")
  api :POST, "/:resource_id/:res_id/links/subnets", N_("Add subnet to :resource")
  api :POST, "/:resource_id/:res_id/links/compute_resources", N_("Add compute resource to :resource")
  api :POST, "/:resource_id/:res_id/links/media", N_("Add medium to :resource")
  api :POST, "/:resource_id/:res_id/links/config_templates", N_("Add provisioning template to :resource")
  api :POST, "/:resource_id/:res_id/links/domains", N_("Add domain to :resource")
  api :POST, "/:resource_id/:res_id/links/realms", N_("Add realm to :resource")
  api :POST, "/:resource_id/:res_id/links/environments", N_("Add environment to :resource")
  api :POST, "/:resource_id/:res_id/links/hostgroups", N_("Add hostgroup to :resource")
  api :POST, "/:resource_id/:res_id/links/:opp_resources", N_("Add :opp_resource to :resource")
  param :res_id, Integer, :desc => N_("id of :resource")
  param :users, Array, :required => false, :desc => N_("Array of user IDs")
  param :smart_proxies, Array, :required => false, :desc => N_("Array of smart proxy IDs")
  param :subnets, Array, :required => false, :desc => N_("Array of subnet IDs")
  param :compute_resources, Array, :required => false, :desc => N_("Array of compute resource IDs")
  param :media, Array, :required => false, :desc => N_("Array of media IDs")
  param :config_templates, Array, :required => false, :desc => N_("Array of template IDs")
  param :domains, Array, :required => false, :desc => N_("Array of domain IDs")
  param :realms, Array, :required => false, :desc => N_("Array of realm IDs")
  param :environments, Array, :required => false, :desc => N_("Array of environment IDs")
  param :hostgroups, Array, :required => false, :desc => N_("Array of hostgroup IDs")
  param :opp_resources, Array, :required => false, :desc => N_("Array of IDs")
  def add
  end

  api :DELETE, "/:resource_id/:res_id/links/users/:id", N_("Remove user from :resource")
  api :DELETE, "/:resource_id/:res_id/links/smart_proxies/:id", N_("Remove smart proxy from :resource")
  api :DELETE, "/:resource_id/:res_id/links/subnets/:id", N_("Remove subnet from :resource")
  api :DELETE, "/:resource_id/:res_id/links/compute_resources/:id", N_("Remove compute resource from :resource")
  api :DELETE, "/:resource_id/:res_id/links/media/:id", N_("Remove medium from :resource")
  api :DELETE, "/:resource_id/:res_id/links/config_templates/:id", N_("Remove provisioning template from :resource")
  api :DELETE, "/:resource_id/:res_id/links/domains/:id", N_("Remove domain from :resource")
  api :DELETE, "/:resource_id/:res_id/links/realms/:id", N_("Remove realm from :resource")
  api :DELETE, "/:resource_id/:res_id/links/environments/:id", N_("Remove environment from :resource")
  api :DELETE, "/:resource_id/:res_id/links/hostgroups/:id", N_("Remove hostgroup from :resource")
  api :DELETE, "/:resource_id/:res_id/links/:opp_resources/:id", N_("Remove :opp_resource from :resource")
  param :res_id, Integer, :desc => N_("id of :resource")
  param :id, String, :required => true, :desc => N_("id or comma-delimited list of id's")
  def remove
  end

  private

  def params_match_database
    # change params[:select_all_types] to params[:ignore_types] to match database
    if params[taxonomy_single.to_sym].try(:[], :select_all_types)
      params[taxonomy_single.to_sym][:ignore_types] = params[taxonomy_single.to_sym][:select_all_types]
      params[taxonomy_single.to_sym]                = params[taxonomy_single.to_sym].reject { |k, v| k == "select_all_types" }
      return params[taxonomy_single.to_sym]
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

end
