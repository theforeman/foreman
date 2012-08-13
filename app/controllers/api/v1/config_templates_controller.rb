module Api
  module V1
    class ConfigTemplatesController < V1::BaseController
      include Foreman::Controller::AutoCompleteSearch
      include Foreman::Renderer

      before_filter :find_resource, :only => [:show, :update, :destroy]
      before_filter :handle_template_upload, :only => [:create, :update]

      api :GET, "/config_templates/", "List templates"
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      def index
        @config_templates = ConfigTemplate.search_for(params[:search], :order => params[:order])
      end

      api :GET, "/config_templates/:id", "Show template details"
      def show
      end

      api :POST, "/config_templates/", "Create a template"
      param :config_template, Hash, :required => true do
        param :name, String, :required => true, :desc => "template name"
        param :template, [String, File], :required => true
        param :snippet, :bool
        param :audit_comment, String
        param :template_kind_id, :number, :desc => "not relevant for snippet"
        param 'template_combinations_attributes', Array, :desc => "Array of template combinations (hostgroup_id, environment_id)"
      end
      def create
        @config_template = ConfigTemplate.new(params[:config_template])
        process_response @config_template.save
      end

      api :PUT, "/config_templates/:id", "Update a template"
      param :config_template, Hash, :required => true do
        param :name, String, :required => true, :desc => "template name"
        param :template, [String, File], :required => true
        param :snippet, :bool
        param :audit_comment, String
        param :template_kind_id, :number, :desc => "not relevant for snippet"
        param 'template_combinations_attributes', Array, :desc => "Array of template combinations (hostgroup_id, environment_id)"
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
      def destroy
        process_response @config_template.destroy
      end

      api :GET, "/config_templates/build_pxe_default", "Change the default PXE menu on all configured TFTP servers"
      def build_pxe_default
        if (proxies = Subnet.all.map(&:tftp).uniq.compact).empty?
          error_msg = "No TFTP proxies defined, can't continue"
        end

        if (default_template = ConfigTemplate.find_by_name("PXE Default File")).nil?
          error_msg = "Could not find a Configuration Template with the name \"PXE Default File\", please create one."
        else
          begin
            @profiles = pxe_default_combos
            menu = render_safe(default_template.template, [:default_template_url], {:profiles => @profiles})
          rescue => e
            error_msg = "failed to process template: #{e}"
          end
        end

        unless error_msg.empty?
          render :json => error_msg, :status => :unprocessable_entity and return
        end

        error_msgs = []
        proxies.each do |proxy|
          begin
            tftp = ProxyAPI::TFTP.new(:url => proxy.url)
            tftp.create_default({:menu => menu})

            @profiles.each do |combo|
              combo[:hostgroup].operatingsystem.pxe_files(combo[:hostgroup].medium, combo[:hostgroup].architecture).each do |bootfile_info|
                for prefix, path in bootfile_info do
                  tftp.fetch_boot_file(:prefix => prefix.to_s, :path => path)
                end
              end
            end
          rescue Exception => exc
            error_msgs << "#{proxy}: #{exc.message}"
          end
        end

        if error_msgs.empty?
          head :status => :ok
        else
          msg = "There was an error creating the PXE Default file: #{error_msgs.join(",")}"
          render :json => msg, :status => 500
        end
      end

      private

      # get a list of all hostgroup, template combinations that a pxemenu will be
      # generated for
      def pxe_default_combos
        combos = []
        ConfigTemplate.joins(:template_kind).where("template_kinds.name" => "provision").each do |template|
          template.template_combinations.each do |combination|
            hostgroup = combination.hostgroup
            if hostgroup and hostgroup.operatingsystem and hostgroup.architecture and hostgroup.medium
              combos << {:hostgroup => hostgroup, :template => template}
            end
          end
        end
        combos
      end

      def default_template_url(template, hostgroup)
        url_for :only_path => false, :action => :template, :controller => :unattended, :id => template.name, :hostgroup => hostgroup.name
      end

      # convert the file upload into a simple string to save in our db.
      def handle_template_upload
        return unless params[:config_template] and (t=params[:config_template][:template])
        params[:config_template][:template] = t.read if t.respond_to?(:read)
      end

    end
  end
end