module Api
  module V1
    class OperatingsystemsController < V1::BaseController
      resource_description do
        name 'Operating systems'
      end

      before_filter :rename_config_templates, :only => %w{update create}
      before_filter :find_resource, :only => %w{show edit update destroy bootfiles}

      api :GET, "/operatingsystems/", "List all operating systems."
      param :search, String, :desc => "filter results", :required => false
      param :order, String, :desc => "sort results", :required => false
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @operatingsystems = Operatingsystem.
          authorized(:view_operatingsystems).
          includes(:media, :architectures, :ptables, :provisioning_templates, :os_default_templates).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/operatingsystems/:id/", "Show an OS."
      param :id, String, :required => true

      def show
      end

      api :POST, "/operatingsystems/", "Create an OS."
      param :operatingsystem, Hash, :required => true do
        param :name, /\A(\S+)\Z/, :required => true
        param :major, String, :required => true
        param :minor, String
        param :description, String
        param :family, String
        param :release_name, String
        param :password_hash, String, :desc => 'Root password hash function to use, one of MD5, SHA256, SHA512, Base64'
        param :config_template_ids, Array, :desc => "IDs of associated provisioning templates" # FIXME: deprecated
        param :provisioning_template_ids, Array, :desc => "IDs of associated provisioning templates"
      end

      def create
        @operatingsystem = Operatingsystem.new(params[:operatingsystem])
        process_response @operatingsystem.save
      end

      api :PUT, "/operatingsystems/:id/", "Update an OS."
      param :id, String, :required => true
      param :operatingsystem, Hash, :required => true do
        param :name, /\A(\S+)\Z/
        param :major, String
        param :minor, String
        param :description, String
        param :family, String
        param :release_name, String
        param :password_hash, String, :desc => 'Root password hash function to use, one of MD5, SHA256, SHA512, Base64'
        param :config_template_ids, Array, :desc => "IDs of associated provisioning templates" # FIXME: deprecated
        param :provisioning_template_ids, Array, :desc => "IDs of associated provisioning templates"
      end

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
        medium = Medium.authorized(:view_media).find(params[:medium])
        arch   = Architecture.authorized(:view_architectures).find(params[:architecture])
        render :json => @operatingsystem.pxe_files(medium, arch)
      rescue => e
        render :json => e.to_s, :status => :unprocessable_entity
      end

      private

      def rename_config_templates
        if params[:operatingsystem] && params[:operatingsystem][:config_template_ids].present?
          params[:operatingsystem][:provisioning_template_ids] = params[:operatingsystem].delete(:config_template_ids)
          Foreman::Deprecation.api_deprecation_warning('Config templates were renamed to provisioning templates')
        end
      end
    end
  end
end
