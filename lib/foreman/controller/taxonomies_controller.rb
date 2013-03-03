module Foreman::Controller::TaxonomiesController
  extend ActiveSupport::Concern

  included do
    before_filter :find_taxonomy, :only => %w{edit update destroy clone_taxonomy assign_hosts
                                            assign_selected_hosts assign_all_hosts step2 select}
    before_filter :count_nil_hosts, :only => %w{index create step2}
    skip_before_filter :authorize, :set_taxonomy, :only => %w{select clear}
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
        @taxonomies = values.paginate(:page => params[:page])
        @counter = Host.group(taxonomy_id).where(taxonomy_id => values).count
        render 'taxonomies/index'
      end
    end
  end

  def new
    @taxonomy = taxonomy_class.new
    Taxonomy.no_taxonomy_scope do
      # we explicitly render here in order to evaluate the view without taxonomy scope
      render 'taxonomies/new'
    end
  end

  # cannot name this method "clone" since Object has a clone method and the mixin doesn't overwrite it
  def clone_taxonomy
    @old_name = @taxonomy.name
    @taxonomy = @taxonomy.clone
    render 'taxonomies/clone'
  end

  def create
    @taxonomy = taxonomy_class.new(params[taxonomy_single.to_sym])
    if @taxonomy.save
      if @count_nil_hosts > 0
        redirect_to send("step2_#{taxonomy_single}_path",@taxonomy)
      else
        process_success(:object => @taxonomy)
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
      (params[taxonomy_single.to_sym][:ignore_types] -= ["0"]) if params[taxonomy_single.to_sym][:ignore_types]
      @taxonomy.update_attributes(params[taxonomy_single.to_sym])
    end
    if result
      process_success(:object => @taxonomy)
    else
      process_error(:render => "taxonomies/edit", :object => @taxonomy)
    end
  end

  def destroy
    if @taxonomy.destroy
      process_success
    else
      process_error
    end
  end

  def select
    taxonomy_class.current = @taxonomy
    session[taxonomy_id] = @taxonomy ? @taxonomy.id : nil

    expire_fragment("tabs_and_title_records-#{User.current.id}")
    redirect_back_or_to root_url
  end

  def clear
    taxonomy_class.current = nil
    session[taxonomy_id] = nil

    expire_fragment("tabs_and_title_records-#{User.current.id}")
    redirect_back_or_to root_url
  end

  def mismatches
    @mismatches = Taxonomy.all_mismatcheds
    render 'taxonomies/mismatches'
  end

  def import_mismatches
    @taxonomy = Taxonomy.find_by_id(params[:id])
    if @taxonomy
      @mismatches = @taxonomy.import_missing_ids
      redirect_to send("edit_#{taxonomy_single}_path", @taxonomy), :notice => "All mismatches between hosts and #{@taxonomy.name} have been fixed"
    else
      Taxonomy.all_import_missing_ids
      redirect_to send("#{taxonomies_plural}_path"), :notice => "All mismatches between hosts and locations/organizations have been fixed"
    end
  end

  def assign_hosts
    @taxonomy_type = taxonomy_single.classify
    @hosts = Host.my_hosts.send("no_#{taxonomy_single}").search_for(params[:search],:order => params[:order]).paginate :page => params[:page], :include => included_associations
    render "hosts/assign_hosts"
  end

  def assign_all_hosts
    Host.send("no_#{taxonomy_single}").update_all(taxonomy_id => @taxonomy.id)
    @taxonomy.import_missing_ids
    redirect_to send("#{taxonomies_plural}_path"), :notice => "All hosts previously with no #{taxonomy_single} are now assigned to #{@taxonomy.name}"
  end

  def assign_selected_hosts
    host_ids = params[taxonomy_single.to_sym][:host_ids] - ["0"]
    @hosts = Host.where(:id => host_ids).update_all(taxonomy_id => @taxonomy.id)
    @taxonomy.import_missing_ids
    redirect_to send("#{taxonomies_plural}_path"), :notice => "Selected hosts are now assigned to #{@taxonomy.name}"
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

  def find_taxonomy
    case controller_name
      when 'organizations'
        @taxonomy = @organization = Organization.find(params[:id])
      when 'locations'
        @taxonomy = @location = Location.find(params[:id])
    end
  end

  def count_nil_hosts
    return @count_nil_hosts if @count_nil_hosts
    @count_nil_hosts = Host.where(taxonomy_id => nil).count
  end

end
