module Api
  module V2
    class OsDefaultTemplatesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_required_nested_object
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, '/operatingsystems/:operatingsystem_id/os_default_templates', N_('List default templates combinations for an operating system')
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @os_default_templates = nested_obj.os_default_templates.paginate(paginate_options)
        @total = nested_obj.os_default_templates.count
      end

      api :GET, "/operatingsystems/:operatingsystem_id/os_default_templates/:id", N_("Show a default template combination for an operating system")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param :id, :number, :required => true

      def show
      end

      def_param_group :os_default_template do
        param :os_default_template, Hash, :action_aware => true do
          param :template_kind_id, :number
          param :config_template_id, :number
        end
      end

      api :POST, "/operatingsystems/:operatingsystem_id/os_default_templates/", N_("Create a default template combination for an operating system")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param_group :os_default_template, :as => :create

      def create
        @os_default_template = nested_obj.os_default_templates.new(params[:os_default_template])
        process_response @os_default_template.save
      end

      api :PUT, "/operatingsystems/:operatingsystem_id/os_default_templates/:id", N_("Update a default template combination for an operating system")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param :id, String, :required => true
      param_group :os_default_template

      def update
        process_response @os_default_template.update_attributes(params[:os_default_template])
      end

      api :DELETE, "/operatingsystems/:operatingsystem_id/os_default_templates/:id", N_("Delete a default template combination for an operating system")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param :id, String, :required => true

      def destroy
        process_response @os_default_template.destroy
      end

      private

      def allowed_nested_id
        %w(operatingsystem_id)
      end


    end
  end
end
