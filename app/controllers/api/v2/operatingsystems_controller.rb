module Api
  module V2
    class OperatingsystemsController < V2::BaseController

      resource_description do
        name 'Operating systems'
      end

      before_filter :find_resource, :only => %w{show edit update destroy bootfiles}

      api :GET, "/operatingsystems/", "List all operating systems."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false, :desc => "for example, name ASC, or name DESC"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @operatingsystems = Operatingsystem.
          authorized(:view_operatingsystems).
          includes(:media, :architectures, :ptables, :config_templates, :os_default_templates).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/operatingsystems/:id/", "Show an OS."
      param :id, String, :required => true

      def show
      end

      def_param_group :operatingsystem do
        param :name, /\A(\S+)\Z/, :required => true, :action_aware => true
        param :major, String, :required => true, :action_aware => true
        param :minor, String
        param :description, String
        param :family, String
        param :release_name, String
      end

      api :POST, "/operatingsystems/", "Create an OS."
      param_group :operatingsystem, :as => :create

      def create
        @operatingsystem = Operatingsystem.new(params[:operatingsystem])
        process_response @operatingsystem.save
      end

      api :PUT, "/operatingsystems/:id/", "Update an OS."
      param :id, String, :required => true
      param_group :operatingsystem

      def update
        process_response @operatingsystem.update_attributes(params[:operatingsystem])
      end

      api :DELETE, "/operatingsystems/:id/", "Delete an OS."
      param :id, String, :required => true

      def destroy
        process_response @operatingsystem.destroy
      end

      api :GET, "/operatingsystems/:id/bootfiles/", "List boot files an OS."
      param :id, String, :required => true
      param :medium, String
      param :architecture, String

      def bootfiles
        medium = Medium.authorized(:view_media).find_by_name(params[:medium])
        arch   = Architecture.authorized(:view_architectures).find_by_name(params[:architecture])
        render :json => @operatingsystem.pxe_files(medium, arch)
      rescue => e
        render :json => e.to_s, :status => :unprocessable_entity
      end

      protected

      def resource_identifying_attributes
        %w(to_label id)
      end

    end
  end
end
