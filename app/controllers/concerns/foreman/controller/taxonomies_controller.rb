module Foreman::Controller::TaxonomiesController
  extend ActiveSupport::Concern

  included do
    before_filter :find_taxonomy, :only => %w{edit update destroy clone_taxonomy assign_systems
                                            assign_selected_systems assign_all_systems step2 select}
    before_filter :count_nil_systems, :only => %w{index create step2}
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
        @counter = System.group(taxonomy_id).where(taxonomy_id => values).count
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

  # cannot name this method "clone" since Object has a clone method and the mixin doesn't overwrite it
  def clone_taxonomy
    @old_name = @taxonomy.name
    @taxonomy = @taxonomy.dup
    render 'taxonomies/clone'
  end

  def create
    @taxonomy = taxonomy_class.new(params[taxonomy_single.to_sym])
    if @taxonomy.save
      if @count_nil_systems > 0
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
      clear_current_taxonomy_from_session if session[taxonomy_id] == @taxonomy.id
      process_success
    else
      process_error
    end
  end

  def select
    taxonomy_class.current = @taxonomy
    session[taxonomy_id] = @taxonomy ? @taxonomy.id : nil

    TopbarSweeper.expire_cache(self)
    redirect_back_or_to root_url
  end

  def clear
    clear_current_taxonomy_from_session
    redirect_back_or_to root_url
  end

  def clear_current_taxonomy_from_session
    taxonomy_class.current = nil
    session[taxonomy_id] = nil
    TopbarSweeper.expire_cache(self)
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
      redirect_to send("edit_#{taxonomy_single}_path", @taxonomy), :notice => _("All mismatches between systems and %s have been fixed") % @taxonomy.name
    else
      Taxonomy.all_import_missing_ids
      redirect_to send("#{taxonomies_plural}_path"), :notice => _("All mismatches between systems and locations/organizations have been fixed")
    end
  end

  def assign_systems
    @taxonomy_type = taxonomy_single.classify
    @systems = System.my_systems.send("no_#{taxonomy_single}").includes(included_associations).search_for(params[:search],:order => params[:order]).paginate(:page => params[:page])
    render "systems/assign_systems"
  end

  def assign_all_systems
    System.send("no_#{taxonomy_single}").update_all(taxonomy_id => @taxonomy.id)
    @taxonomy.import_missing_ids
    redirect_to send("#{taxonomies_plural}_path"), :notice => _("All systems previously with no %{single} are now assigned to %{name}") % { :single => taxonomy_single, :name => @taxonomy.name }
  end

  def assign_selected_systems
    system_ids = params[taxonomy_single.to_sym][:system_ids] - ["0"]
    @systems = System.where(:id => system_ids).update_all(taxonomy_id => @taxonomy.id)
    @taxonomy.import_missing_ids
    redirect_to send("#{taxonomies_plural}_path"), :notice => _("Selected systems are now assigned to %s") % @taxonomy.name
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

  def count_nil_systems
    return @count_nil_systems if @count_nil_systems
    @count_nil_systems = System.where(taxonomy_id => nil).count
  end

end
