module Foreman::Controller::TaxonomiesController
  extend ActiveSupport::Concern

  included do
    before_action :find_resource, :only => %w{edit update destroy clone_taxonomy assign_hosts
                                              assign_selected_hosts assign_all_hosts step2 select
                                              parent_taxonomy_selected}
    before_action :count_nil_hosts, :only => %w{index create step2}
    before_action :new_taxonomy, :only => %w{create}
    skip_before_action :authorize, :set_taxonomy, :only => %w{select clear}
  end

  def index
    begin
      values = taxonomy_class.send("my_#{taxonomies_plural}").search_for(params[:search], :order => params[:order])
    rescue => e
      error e.to_s
      values = taxonomy_class.send("my_#{taxonomies_plural}")
    end

    respond_to do |format|
      format.html do
        @taxonomies = values.paginate(:page => params[:page], :per_page => params[:per_page])
        render 'taxonomies/index'
      end
      format.json
    end
  end

  def new
    @taxonomy = taxonomy_class.new
    Taxonomy.no_taxonomy_scope do
      # we explicitly render here in order to evaluate the view without taxonomy scope
      render 'taxonomies/new'
    end
  end

  def nest
    @taxonomy           = taxonomy_class.new
    @taxonomy.parent_id = params[:id].to_i if resource_scope.find_by_id(params[:id])
    render 'taxonomies/new'
  end

  # cannot name this method "clone" since Object has a clone method and the mixin doesn't overwrite it
  def clone_taxonomy
    @old_name = @taxonomy.name
    @taxonomy = @taxonomy.dup
    render 'taxonomies/clone'
  end

  def create
    if @taxonomy.save
      switch_taxonomy
      if @count_nil_hosts > 0
        redirect_to send("step2_#{taxonomy_single}_path", @taxonomy)
      else
        process_success(:object => @taxonomy, :success_redirect => send("edit_#{taxonomy_single}_path", @taxonomy))
      end
    else
      process_error(:render => "taxonomies/new", :object => @taxonomy)
    end
  end

  def edit
    Taxonomy.no_taxonomy_scope do
      # we explicitly render here in order to evaluate the view without taxonomy scope
      render 'taxonomies/edit'
    end
  end

  def step2
    Taxonomy.no_taxonomy_scope do
      render 'taxonomies/step2'
    end
  end

  def update
    result = Taxonomy.no_taxonomy_scope do
      @taxonomy.update(resource_params)
    end
    if result
      process_success(:object => @taxonomy)
    else
      process_error(:render => "taxonomies/edit", :object => @taxonomy)
    end
  end

  def destroy
    if @taxonomy.destroy
      clear_current_taxonomy_from_session if session[taxonomy_id] == @taxonomy.id
      process_success
    else
      process_error
    end
  rescue Ancestry::AncestryException
    process_error(:error_msg => _('Cannot delete %{current} because it has nested %{sti_name}.') % { :current => @taxonomy.title, :sti_name => @taxonomy.sti_name })
  end

  def select
    switch_taxonomy
    redirect_back_or_to root_url
  end

  def clear
    clear_current_taxonomy_from_session
    redirect_back_or_to root_url
  end

  def clear_current_taxonomy_from_session
    taxonomy_class.current = nil
    # session can't store nil, so we use empty string to represent any context
    session[taxonomy_id] = ''
    TopbarSweeper.expire_cache
  end

  def mismatches
    Taxonomy.no_taxonomy_scope do
      @mismatches = Taxonomy.all_mismatcheds
    end
    render 'taxonomies/mismatches'
  end

  def import_mismatches
    @taxonomy = Taxonomy.find_by_id(params[:id])
    if @taxonomy
      @mismatches = @taxonomy.import_missing_ids
      redirect_to send("edit_#{taxonomy_single}_path", @taxonomy), :success => _("All mismatches between hosts and %s have been fixed") % CGI.escapeHTML(@taxonomy.name)
    else
      Taxonomy.all_import_missing_ids
      redirect_to send("#{taxonomies_plural}_path"), :success => _("All mismatches between hosts and locations/organizations have been fixed")
    end
  end

  def assign_hosts
    @taxonomy_type = taxonomy_single.classify
    @hosts = hosts_scope_without_taxonomy.includes(included_associations).search_for(params[:search], :order => params[:order]).paginate(:page => params[:page], :per_page => params[:per_page])
    render "hosts/assign_hosts"
  end

  def assign_all_hosts
    hosts_scope_without_taxonomy.update_all(taxonomy_id => @taxonomy.id)
    @taxonomy.import_missing_ids
    redirect_to send("#{taxonomies_plural}_path"), :success => _("All hosts previously with no %{single} are now assigned to %{name}") % { :single => taxonomy_single, :name => CGI.escapeHTML(@taxonomy.name) }
  end

  def assign_selected_hosts
    host_ids = params[taxonomy_single.to_sym][:host_ids] - ["0"]
    @hosts = hosts_scope_without_taxonomy.where(:id => host_ids).update_all(taxonomy_id => @taxonomy.id)
    @taxonomy.import_missing_ids
    redirect_to send("#{taxonomies_plural}_path"), :success => _("Selected hosts are now assigned to %s") % CGI.escapeHTML(@taxonomy.name)
  end

  def parent_taxonomy_selected
    return head(:not_found) unless @taxonomy
    @taxonomy.parent_id = params[:parent_id]
    render :partial => "taxonomies/form", :locals => {:taxonomy => @taxonomy}
  end

  private

  def taxonomy_id
    case controller_name
      when 'organizations'
        :organization_id
      when 'locations'
        :location_id
    end
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

  # overwrite application_controller
  def find_resource
    if params[:id].blank?
      not_found
      return
    end

    case controller_name
      when 'organizations'
        @taxonomy = @organization = resource_scope.find(params[:id])
      when 'locations'
        @taxonomy = @location = resource_scope.find(params[:id])
    end
  end

  def resource_scope
    taxonomy_class.send("my_#{taxonomies_plural}")
  end

  def count_nil_hosts
    return @count_nil_hosts if @count_nil_hosts
    @count_nil_hosts = hosts_scope_without_taxonomy.count
  end

  def hosts_scope
    Host.authorized(:view_hosts, Host)
  end

  def hosts_scope_without_taxonomy
    hosts_scope.send("no_#{taxonomy_single}")
  end

  def resource_params
    public_send("#{taxonomy_single}_params".to_sym)
  end

  def new_taxonomy
    @taxonomy = taxonomy_class.new(resource_params)
  end

  def switch_taxonomy
    taxonomy_class.current = @taxonomy
    session[taxonomy_id] = @taxonomy ? @taxonomy.id : nil

    TopbarSweeper.expire_cache
  end
end
