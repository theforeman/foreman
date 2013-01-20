module Foreman::Controller::TaxonomiesController
  extend ActiveSupport::Concern

  included do
    before_filter :find_taxonomy, :only => %w{edit update destroy clone assign_hosts
                                            assign_selected_hosts assign_all_hosts step2}
    before_filter :count_nil_hosts, :only => %w{index create step2}
    skip_before_filter :authorize, :set_taxonomy, :only => %w{select}
  end

  module InstanceMethods

    def index
      begin
        values = send("TaxonomyClass").send("my_#{taxonomies}").search_for(params[:search], :order => params[:order])
      rescue => e
        error e.to_s
        values = send("TaxonomyClass").send("my_#{taxonomies}").search_for('')
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
      @taxonomy = send("TaxonomyClass").new
      Taxonomy.no_taxonomy_scope do
        # we explicitly render here in order to evaluate the view without taxonomy scope
        render 'taxonomies/new'
      end
    end

    def clone
      @taxonomy = @taxonomy.clone
      render 'taxonomies/new'
    end

    def create
      @taxonomy = send("TaxonomyClass").new(params[taxonomy.to_sym])
      instance_variable_set("@#{taxonomy}", @taxonomy)
      if @taxonomy.save
        if @count_nil_hosts > 0
          redirect_to send("step2_#{taxonomy}_path",@taxonomy)
        else
          process_success
        end
      else
        process_error
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
        (params[taxonomy.to_sym][:ignore_types] -= ["0"]) if params[taxonomy.to_sym][:ignore_types]
        @taxonomy.update_attributes(params[taxonomy.to_sym])
      end
      if result
        process_success
      else
        process_error
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
      @taxonomy = params[:id] ? Taxonomy.find(params[:id]) : nil
      send("TaxonomyClass").current = @taxonomy
      session[taxonomy_id] = @taxonomy ? @taxonomy.id : nil

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
        redirect_to send("edit_#{taxonomy}_path", @taxonomy), :notice => "All mismatches between hosts and #{@taxonomy.name} have been fixed"
      else
        Taxonomy.all_import_missing_ids
        redirect_to send("#{taxonomies}_path"), :notice => "All mismatches between hosts and locations/organizations have been fixed"
      end
    end

    def assign_hosts
      @taxonomy_type = taxonomy.classify
      @hosts = Host.my_hosts.send("no_#{taxonomy}").search_for(params[:search],:order => params[:order]).paginate :page => params[:page], :include => included_associations
      render "hosts/assign_hosts"
    end

    def assign_all_hosts
      Host.send("no_#{taxonomy}").update_all(taxonomy_id => @taxonomy.id)
      @taxonomy.import_missing_ids
      redirect_to send("#{taxonomies}_path"), :notice => "All hosts previously with no #{taxonomy} are now assigned to #{@taxonomy.name}"
    end

    def assign_selected_hosts
      host_ids = params[taxonomy.to_sym][:host_ids] - ["0"]
      @hosts = Host.where(:id => host_ids).update_all(taxonomy_id => @taxonomy.id)
      @taxonomy.import_missing_ids
      redirect_to send("#{taxonomies}_path"), :notice => "Selected hosts are now assigned to #{@taxonomy.name}"
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

    def taxonomy
      controller_name.singularize
    end

    def taxonomies
      controller_name
    end

    def TaxonomyClass
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
end