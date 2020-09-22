module Api::ImportPuppetclassesCommonController
  extend ActiveSupport::Concern

  included do
    before_action :find_required_puppet_proxy, :only => [:import_puppetclasses]
    before_action :get_environment_id, :only => [:import_puppetclasses]
    before_action :find_optional_environment, :only => [:import_puppetclasses]
  end

  extend Apipie::DSL::Concern

  api :POST, "/smart_proxies/:id/import_puppetclasses", N_("Import puppet classes from puppet proxy")
  api :POST, "/smart_proxies/:smart_proxy_id/environments/:id/import_puppetclasses", N_("Import puppet classes from puppet proxy for an environment")
  api :POST, "/environments/:environment_id/smart_proxies/:id/import_puppetclasses", N_("Import puppet classes from puppet proxy for an environment")
  param :id, :identifier, :required => true
  param :smart_proxy_id, String, :required => false
  param :environment_id, String, :required => false
  param :dryrun, :bool, :required => false
  param :except, String, :required => false, :desc => N_("Optional comma-delimited string containing either 'new', 'updated', or 'obsolete' that is used to limit the imported Puppet classes")

  ALLOWED_KINDS = ["new", "obsolete", "updated", "ignored"]
  def import_puppetclasses
    return unless changed_environments
    # @changed is returned from the method above changed_environments
    # Limit actions by setting @changed[kind] to empty hash {} (no action)
    # if :except parameter is passed with comma deliminator import_puppetclasses?except=new,obsolete
    if params[:except].present?
      kinds = params[:except].split(',')
      kinds.each do |kind|
        @changed[kind] = {} if ALLOWED_KINDS.include?(kind)
      end
    end

    # DRYRUN - /import_puppetclasses?dryrun - do not run PuppetClassImporter
    rabl_template = @environment ? 'show' : 'index'
    if params.key?('dryrun') && !['false', false].include?(params['dryrun'])
      render("api/v#{api_version}/import_puppetclasses/#{rabl_template}", :layout => "api/layouts/import_puppetclasses_layout")
      return
    end

    # RUN PuppetClassImporter
    if (errors = ::PuppetClassImporter.new.obsolete_and_new(@changed)).empty?
      render("api/v#{api_version}/import_puppetclasses/#{rabl_template}", :layout => "api/layouts/import_puppetclasses_layout")
    else
      render :json => {:message => _("Failed to update the environments and Puppet classes from the on-disk puppet installation: %s") % errors.join(", ")}, :status => :internal_server_error
    end
  end

  def changed_environments
    begin
      opts = { :url => @smart_proxy.url }
      if @environment.present?
        opts[:env] = @environment.name
      else
        opts[:env] = @env_id
      end
      @importer = PuppetClassImporter.new(opts)
      @changed  = @importer.changes

      # check if environemnt id passed in URL is name of NEW environment in puppetmaster that doesn't exist in db
      if @environment || (@changed['new'].key?(@env_id) && (@environment ||= OpenStruct.new(:name => @env_id)))
        # only return :keys equal to @environment in @changed hash
        ["new", "obsolete", "updated", "ignored"].each do |kind|
          @changed[kind].slice!(@environment.name) unless @changed[kind].empty?
        end
      end
    rescue => e
      if e.message =~ /puppet feature/i
        msg = _('No proxy found to import classes from, ensure that the smart proxy has the Puppet feature enabled.')
      else
        Foreman::Logging.exception("Error while importing Puppet classes", e)
        msg = e.message
      end
      render_message(msg, :status => :internal_server_error)
      return false
    end

    # PuppetClassImporter expects [kind][env] to be in json format
    ["new", "obsolete", "updated", "ignored"].each do |kind|
      unless (envs = @changed[kind]).empty?
        envs.keys.sort.each do |env|
          @changed[kind][env] = @changed[kind][env].to_json
        end
      end
    end

    # @environments is used in import_puppletclasses/index.json.rabl
    environment_names = (@changed["new"].keys + @changed["obsolete"].keys +
                         @changed["updated"].keys + @changed["ignored"].keys).uniq.sort

    @environments = environment_names.map do |name|
      OpenStruct.new(:name => name)
    end

    unless @environments.any?
      render_message(_("No changes to your environments detected"))
      return false
    end

    @environments.any?
  end

  def find_required_puppet_proxy
    id = params.key?('smart_proxy_id') ? params['smart_proxy_id'] : params['id']
    @smart_proxy = SmartProxy.authorized(:view_smart_proxies).find(id)
    unless @smart_proxy && SmartProxy.with_features("Puppet").pluck("smart_proxies.id").include?(@smart_proxy.id)
      not_found _('No proxy found to import classes from, ensure that the smart proxy has the Puppet feature enabled.')
    end
    @smart_proxy
  end

  def get_environment_id
    @env_id = if params.key?('environment_id')
                params['environment_id']
              elsif controller_name == 'environments' && params['id'].present?
                params['id']
              end
    @env_id
  end

  def find_optional_environment
    @environment = Environment.authorized(:view_environments).find(@env_id)
  rescue ActiveRecord::RecordNotFound => e
    Foreman::Logging.exception("Resource not found", e, :level => :debug)
    nil
  end
end
