module Api
  module V1
    class ConfigTemplatesController < V1::BaseController
      include Foreman::Renderer

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :handle_template_upload, :only => [:create, :update]
      before_filter :process_template_kind, :only => [:create, :update]

      api :GET, "/config_templates/", "List templates"
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @config_templates = ConfigTemplate.search_for(*search_options).paginate(paginate_options).
          includes(:operatingsystems, :template_combinations, :template_kind)
      end

      api :GET, "/config_templates/:id", "Show template details"
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/config_templates/", "Create a template"
      param :config_template, Hash, :required => true do
        param :name, String, :required => true, :desc => "template name"
        param :template, String, :required => true
        param :snippet, :bool, :allow_nil => true
        param :audit_comment, String, :allow_nil => true
        param :template_kind_id, :number, :allow_nil => true, :desc => "not relevant for snippet"
        param :template_combinations_attributes, Array,
              :desc => "Array of template combinations (hostgroup_id, environment_id)"
        param :operatingsystem_ids, Array, :desc => "Array of operating systems ID to associate the template with"
      end

      def create
        @config_template = ConfigTemplate.new(params[:config_template])
        process_response @config_template.save
      end

      api :PUT, "/config_templates/:id", "Update a template"
      param :id, :identifier, :required => true
      param :config_template, Hash, :required => true do
        param :name, String, :desc => "template name"
        param :template, String
        param :snippet, :bool
        param :audit_comment, String, :allow_nil => true
        param :template_kind_id, :number, :allow_nil => true, :desc => "not relevant for snippet"
        param :template_combinations_attributes, Array, :desc => "Array of template combinations (hostgroup_id, environment_id)"
        param :operatingsystem_ids, Array, :desc => "Array of operating systems ID to associate the template with"
      end

      def update
        process_response @config_template.update_attributes(params[:config_template])
      end

      api :GET, "/config_templates/revision"
      param :version, String, :desc => "template version"

      def revision
        audit = Audit.find(params[:version])
        render :json => audit.revision.template
      end

      api :DELETE, "/config_templates/:id", "Delete a template"
      param :id, :identifier, :required => true

      def destroy
        process_response @config_template.destroy
      end

      api :GET, "/config_templates/build_pxe_default", "Change the default PXE menu on all configured TFTP servers"

      def build_pxe_default
        status, msg = ConfigTemplate.build_pxe_default(self)
        render :json => msg, :status => status
      end

      private

      # convert the file upload into a simple string to save in our db.
      def handle_template_upload
        return unless params[:config_template] and (t=params[:config_template][:template])
        params[:config_template][:template] = t.read if t.respond_to?(:read)
      end

      def default_template_url template, hostgroup
        url_for :only_path => false, :action => :template, :controller => :unattended,
                :id        => template.name, :hostgroup => hostgroup.name
      end

      def process_template_kind
        return unless params[:config_template] and (tk=params[:config_template].delete(:template_kind))
        params[:config_template][:template_kind_id] = tk[:id]
      end

    end
  end
end
