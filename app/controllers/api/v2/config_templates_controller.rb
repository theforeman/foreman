module Api
  module V2
    class ConfigTemplatesController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope
      include Foreman::Renderer

      before_filter(:only => %w{show update destroy}) { find_resource('templates') }
      before_filter :handle_template_upload, :only => [:create, :update]
      before_filter :process_template_kind, :only => [:create, :update]
      before_filter :process_operatingsystems, :only => [:create, :update]

      api :GET, "/config_templates/", N_("List provisioning templates")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @config_templates = ConfigTemplate.
          authorized(:view_templates).
          search_for(*search_options).paginate(paginate_options).
          includes(:operatingsystems, :template_combinations, :template_kind)
      end

      api :GET, "/config_templates/:id", N_("Show provisioning template details")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :config_template do
        param :config_template, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("template name")
          param :template, String, :required => true
          param :snippet, :bool, :allow_nil => true
          param :audit_comment, String, :allow_nil => true
          param :template_kind_id, :number, :allow_nil => true, :desc => N_("not relevant for snippet")
          param :template_combinations_attributes, Array,
                :desc => N_("Array of template combinations (hostgroup_id, environment_id)")
          param :operatingsystem_ids, Array, :desc => N_("Array of operating system IDs to associate with the template")
          param :locked, :bool, :desc => N_("Whether or not the template is locked for editing")
        end
      end

      api :POST, "/config_templates/", N_("Create a provisioning template")
      param_group :config_template, :as => :create

      def create
        @config_template = ConfigTemplate.new(params[:config_template])
        process_response @config_template.save
      end

      api :PUT, "/config_templates/:id", N_("Update a provisioning template")
      param :id, :identifier, :required => true
      param_group :config_template

      def update
        process_response @config_template.update_attributes(params[:config_template])
      end

      api :GET, "/config_templates/revision"
      param :version, String, :desc => N_("template version")

      def revision
        audit = Audit.authorized(:view_audit_logs).find(params[:version])
        render :json => audit.revision.template
      end

      api :DELETE, "/config_templates/:id", N_("Delete a provisioning template")
      param :id, :identifier, :required => true

      def destroy
        process_response @config_template.destroy
      end

      api :GET, "/config_templates/build_pxe_default", N_("Update the default PXE menu on all configured TFTP servers")

      def build_pxe_default
        status, msg = ConfigTemplate.authorized(:deploy_templates).build_pxe_default(self)
        render :json => msg, :status => status
      end

      private

      # convert the file upload into a simple string to save in our db.
      def handle_template_upload
        return unless params[:config_template] and (t=params[:config_template][:template])
        params[:config_template][:template] = t.read if t.respond_to?(:read)
      end

      def default_template_url template, hostgroup
        url_for :only_path => false, :action => :template, :controller => '/unattended',
                :id        => template.name, :hostgroup => hostgroup.name
      end

      def process_template_kind
        return unless params[:config_template] and (tk=params[:config_template].delete(:template_kind))
        params[:config_template][:template_kind_id] = tk[:id]
      end

      def process_operatingsystems
        return unless (ct = params[:config_template]) and (operatingsystems = ct.delete(:operatingsystems))
        ct[:operatingsystem_ids] = operatingsystems.collect {|os| os[:id]}
      end

    end
  end
end
