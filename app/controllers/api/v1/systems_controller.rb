module Api
  module V1
    class SystemsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy status}

      api :GET, "/systems/", "List all systems."
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @systems = System.my_systems.search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/systems/:id/", "Show a system."
      param :id, :identifier_dottable, :required => true

      def show
      end

      api :POST, "/systems/", "Create a system."
      param :system, Hash, :required => true do
        param :name, String, :required => true
        param :environment_id, String
        param :ip, String, :desc => "not required if using a subnet with dhcp proxy"
        param :mac, String, :desc => "not required if its a virtual machine"
        param :architecture_id, :number
        param :domain_id, :number
        param :puppet_proxy_id, :number
        param :puppet_class_ids, Array
        param :operatingsystem_id, String
        param :medium_id, :number
        param :ptable_id, :number
        param :subnet_id, :number
        param :compute_resource_id, :number
        param :sp_subnet_id, :number
        param :model_id, :number
        param :system_group_id, :number
        param :owner_id, :number
        param :puppet_ca_proxy_id, :number
        param :image_id, :number
        param :system_parameters_attributes, Array
        param :build, :bool
        param :enabled, :bool
        param :provision_method, String
        param :managed, :bool
        param :progress_report_id, String, :desc => 'UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks'
        param :capabilities, String
        param :compute_attributes, Hash do
        end
      end

      def create
        @system = System.new(params[:system])
        @system.managed = true if (params[:system] && params[:system][:managed].nil?)
        forward_request_url
        process_response @system.save
      end

      api :PUT, "/systems/:id/", "Update a system."
      param :id, :identifier, :required => true
      param :system, Hash, :required => true do
        param :name, String
        param :environment_id, String
        param :ip, String, :desc => "not required if using a subnet with dhcp proxy"
        param :mac, String, :desc => "not required if its a virtual machine"
        param :architecture_id, :number
        param :domain_id, :number
        param :puppet_proxy_id, :number
        param :operatingsystem_id, String
        param :puppet_class_ids, Array
        param :medium_id, :number
        param :ptable_id, :number
        param :subnet_id, :number
        param :compute_resource_id, :number
        param :sp_subnet_id, :number
        param :model_id, :number
        param :system_group_id, :number
        param :owner_id, :number
        param :puppet_ca_proxy_id, :number
        param :image_id, :number
        param :system_parameters_attributes, Array
        param :build, :bool
        param :enabled, :bool
        param :provision_method, String
        param :managed, :bool
        param :progress_report_id, String, :desc => 'UUID to track orchestration tasks status, GET /api/orchestration/:UUID/tasks'
        param :capabilities, String
        param :compute_attributes, Hash do
        end
      end

      def update
        process_response @system.update_attributes(params[:system])
      end

      api :DELETE, "/systems/:id/", "Delete an system."
      param :id, :identifier, :required => true

      def destroy
        process_response @system.destroy
      end

      api :GET, "/systems/:id/status", "Get status of system"
      param :id, :identifier_dottable, :required => true
      # TRANSLATORS: API documentation - do not translate
      description <<-eos
Return value may either be one of the following:

* missing
* failed
* pending
* changed
* unchanged
* unreported

      eos

      def status
        render :json => { :status => @system.system_status }.to_json if @system
      end

      # we need to limit resources for a current user
      def resource_scope
        resource_class.my_systems
      end

      private

      # this is required for template generation (such as pxelinux) which is not done via a web request
      def forward_request_url
        @system.request_url = request.system_with_port if @system.respond_to?(:request_url)
      end
    end
  end
end
