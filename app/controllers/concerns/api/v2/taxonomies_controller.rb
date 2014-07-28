module Api::V2::TaxonomiesController
  extend ActiveSupport::Concern

  included do
    before_filter :find_taxonomy, :only => %w{show update destroy settings
                                                domain_ids subnet_ids hostgroup_ids config_template_ids compute_resource_ids
                                                medium_ids smart_proxy_ids environment_ids user_ids organization_ids realm_ids
                                                }
    before_filter :find_optional_nested_object, :only => %w(index show)
    before_filter :params_match_database, :only => %w(create update)
  end

  extend Apipie::DSL::Concern

  def_param_group :resource do
    param :name, String, :required => true, :action_aware => true
  end

  api :GET, '/:resource_id', 'List all :resource_id'
  param :search, String, :desc => "filter results"
  param :order, String, :desc => "sort results"
  param :page, String, :desc => "paginate results"
  param :per_page, String, :desc => "number of entries per request"
  def index
    if @nested_obj
      #@taxonomies = @domain.locations.search_for(*search_options).paginate(paginate_options)
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

  api :GET, '/:resource_id/:id', 'Show :a_resource'
  def show
    @render_template ||= 'api/v2/taxonomies/show'
    render @render_template
  end

  api :POST, '/:resource_id', 'Create :a_resource'
  param_group :resource, :as => :create
  def create
    @taxonomy = taxonomy_class.new(params[taxonomy_single.to_sym])
    instance_variable_set("@#{taxonomy_single}", @taxonomy)
    process_response @taxonomy.save
  end

  api :PUT, '/:resource_id/:id', 'Update :a_resource'
  param_group :resource
  def update
    # NOTE - if not ! and invalid, the error is undefined method `permission_failed?' for #<Location:0x7fe38c1d3ec8> (NoMethodError)
    # removed process_response & added explicit render 'api/v2/taxonomies/update'.  Otherwise, *_ids are not returned

    process_response  @taxonomy.update_attributes(params[taxonomy_single.to_sym])
  end

  api :DELETE, '/:resource_id/:id', 'Delete :a_resource'
  def destroy
    process_response @taxonomy.destroy
  rescue Ancestry::AncestryException
    render :json => {:error => {:message => (_('Cannot delete %{current} because it has nested %{sti_name}.') % { :current => @taxonomy.title, :sti_name => @taxonomy.sti_name }) } }
  end

  private

  def params_match_database
    # change params[:select_all_types] to params[:ignore_types] to match database
    if params[taxonomy_single.to_sym][:select_all_types]
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
