module Api::ImportPuppetclassesCommonController
  extend ActiveSupport::Concern

  included do
    before_filter :find_required_puppet_proxy, :only => [:import_puppetclasses]
    before_filter :find_optional_environment, :only => [:import_puppetclasses]
  end

  extend Apipie::DSL::Concern

  api :GET, "/smart_proxies/:id/import_puppetclasses", "Import puppetclasses from puppet proxy."
  api :GET, "/smart_proxies/:smart_proxy_id/environments/:id/import_puppetclasses", "Import puppetclasses from puppet proxy for particular environment."
  api :GET, "/environments/:environment_id/smart_proxies/:id/import_puppetclasses", "Import puppetclasses from puppet proxy for particular environment."
  param :smart_proxy_id, :identifier, :required => true
  param :environment_id, :identifier, :required => false
  param :dryrun, String, :required => false

  def import_puppetclasses
    render(:json => {:message => "No changes to your environments detected"}) and return unless changed_environments

    # DRYRUN - /import_puppetclasses?dryrun - do not run PuppetClassImporter
    rabl_template = @environment ? 'show' : 'index'
    render("api/v1/import_puppetclasses/#{rabl_template}", :layout => "api/layouts/import_puppetclasses_layout") and return if params.keys.include?('dryrun')

    # RUN PuppetClassImporter
    if (errors = ::PuppetClassImporter.new.obsolete_and_new(@changed)).empty?
      render("api/v1/import_puppetclasses/#{rabl_template}", :layout => "api/layouts/import_puppetclasses_layout")
    else
      render :json => {:message => "Failed to update the environments and puppetclasses from the on-disk puppet installation #{errors.join(", ")}"}
    end
  end

  def changed_environments
    begin
      opts      =  { :url => @smart_proxy.url }
      @importer = PuppetClassImporter.new(opts)
      @changed  = @importer.changes

      if @environment
        # only return :keys equal to @environment in @changed hash
        ["new", "obsolete", "updated"].each do |kind|
          @changed[kind].slice!(@environment.name) unless @changed[kind].empty?
        end
      end

    rescue => e
      if e.message =~ /puppet feature/i
      msg = 'We did not find a foreman proxy that can provide the information, ensure that this proxy has the puppet feature turned on.'
      render :json => {:message => msg}, :status => :not_found and return false
      end
    end

    # PuppetClassImporter expects [kind][env] to be in json format
    ["new", "obsolete", "updated"].each do |kind|
      unless (envs = @changed[kind]).empty?
        envs.keys.sort.each do |env|
          @changed[kind][env] = @changed[kind][env].to_json
        end
      end
    end

    # @environments is used in import_puppletclasses/index.json.rabl
    environments_new = @changed["new"].size > 0 ? @changed["new"].keys : []
    environments_obsolete = @changed["obsolete"].size > 0 ? @changed["obsolete"].keys : []
    environments_updated = @changed["updated"].size > 0 ? @changed["updated"].keys : []
    environment_names = (environments_new + environments_obsolete + environments_updated).uniq.sort
    @environments = environment_names.map do |name|
      OpenStruct.new(:name => name)
    end
    @environments.any?
  end

  def find_required_puppet_proxy
    id = params.keys.include?('smart_proxy_id') ? params['smart_proxy_id'] : params['id']
    @smart_proxy   = SmartProxy.find_by_id(id.to_i) if id.to_i > 0
    @smart_proxy ||= SmartProxy.find_by_name(id)
    unless @smart_proxy && SmartProxy.puppet_proxies.pluck(:id).include?(@smart_proxy.id)
      msg = 'We did not find a foreman proxy that can provide the information, ensure that this proxy has the puppet feature turned on.'
      render :json => {:message => msg}, :status => :not_found and return false
    end
    @smart_proxy
  end

  def find_optional_environment
    id = params.keys.include?('environment_id') ? params['environment_id'] : params['id']
    @environment   = Environment.find_by_id(id.to_i) if id.to_i > 0
    @environment ||= Environment.find_by_name(id)
    @environment
  end

end
