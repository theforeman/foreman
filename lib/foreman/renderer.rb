require 'tempfile'

module Foreman
  module Renderer
    # foreman_url macro uses url_for, therefore we need url helpers and fake default_url_options
    # if it's not defined in class the we mix into
    include Rails.application.routes.url_helpers

    def default_url_options
      {}
    end

    ALLOWED_GENERIC_HELPERS ||= [ :foreman_url, :snippet, :snippets, :snippet_if_exists, :indent, :foreman_server_fqdn,
                                  :foreman_server_url, :log_debug, :log_info, :log_warn, :log_error, :log_fatal, :template_name, :dns_lookup,
                                  :pxe_kernel_options ]
    ALLOWED_HOST_HELPERS ||= [ :grub_pass, :ks_console, :root_pass,
                               :media_path, :param_true?, :param_false?, :match ]

    ALLOWED_HELPERS ||= ALLOWED_GENERIC_HELPERS + ALLOWED_HOST_HELPERS

    ALLOWED_VARIABLES ||= [ :arch, :host, :osver, :mediapath, :mediaserver, :static,
                            :repos, :dynamic, :kernel, :initrd, :xen,
                            :preseed_server, :preseed_path, :provisioning_type, :template_name ]

    def template_logger
      @template_logger ||= Foreman::Logging.logger('templates')
    end

    def render_safe(template, allowed_methods = [], allowed_vars = {})
      if Setting[:safemode_render]
        box = Safemode::Box.new self, allowed_methods
        box.eval(ERB.new(template, nil, '-').src, allowed_vars)
      else
        allowed_vars.each { |k,v| instance_variable_set "@#{k}", v }
        ERB.new(template, nil, '-').result(binding)
      end
    end

    #returns the URL for Foreman Built status (when a host has finished the OS installation)
    def foreman_url(action = "built")
      # Get basic stuff
      config   = URI.parse(Setting[:unattended_url])
      protocol = config.scheme || 'http'
      host     = config.host || request.host
      port     = config.port || request.port
      path     = config.path

      proxy = @host.try(:subnet).try(:tftp)

      # use template_url from the request if set, but otherwise look for a Template
      # feature proxy, as PXE templates are written without an incoming request.
      url = if @template_url
              @template_url
            elsif proxy.present? && proxy.has_feature?('Templates')
              temp_url = ProxyAPI::Template.new(:url => proxy.url).template_url
              if temp_url.nil?
                template_logger.warn("unable to obtain template url set by proxy #{proxy.url}. falling back on proxy url.")
                temp_url = proxy.url
              end
              temp_url
            end

      if url.present?
        uri      = URI.parse(url)
        host     = uri.host
        port     = uri.port
        protocol = uri.scheme
        path     = config.path
      end

      url_for :only_path => false, :controller => "/unattended", :action => 'host_template',
              :protocol  => protocol, :host => host, :port => port, :script_name => path,
              :token     => (@host.token.value unless @host.try(:token).nil?), :kind => action
    end

    def foreman_server_fqdn
      config = URI.parse(Setting[:foreman_url])
      config.host
    end

    def foreman_server_url
      Setting[:foreman_url]
    end

    class_eval do
      [:debug, :info, :warn, :error, :fatal].each do |level|
        define_method("log_#{level}".to_sym) do |msg|
          template_logger.send(level, msg) if msg.present?
        end
      end
    end

    def template_name
      @template_name || 'Unnamed'
    end

    def pxe_kernel_options
      return '' unless @host || @host.operatingsystem
      @host.operatingsystem.pxe_kernel_options(@host.params).join(' ')
    rescue => e
      template_logger.warn "Unable to build PXE kernel options: #{e}"
      ''
    end

    # provide embedded snippets support as simple erb templates
    def snippets(file)
      if Template.where(:name => file, :snippet => true).empty?
        render :partial => "unattended/snippets/#{file}"
      else
        return snippet(file.gsub(/^_/, ""))
      end
    end

    def snippet(name, options = {})
      if (template = Template.where(:name => name, :snippet => true).first)
        begin
          return unattended_render(template)
        rescue => exc
          raise "The snippet '#{name}' threw an error: #{exc}"
        end
      else
        if options[:silent]
          nil
        else
          raise "The specified snippet '#{name}' does not exist, or is not a snippet."
        end
      end
    end

    def snippet_if_exists(name)
      snippet name, :silent => true
    end

    def indent(count)
      return unless block_given? && (text = yield.to_s)
      prefix = " " * count
      prefix + text.gsub(/\n/, "\n#{prefix}")
    end

    def dns_lookup(name_or_ip)
      resolver = Resolv::DNS.new
      Timeout.timeout(Setting[:dns_conflict_timeout]) do
        begin
          resolver.getname(IPAddr.new(name_or_ip))
        rescue IPAddr::Error
          resolver.getaddress(name_or_ip)
        end
      end
    rescue => e
      log_warn "Template helper dns_lookup failed: #{e}"
      raise e
    end

    # accepts either template object or plain string
    def unattended_render(template, overridden_name = nil)
      @template_name = template.respond_to?(:name) ? template.name : (overridden_name || 'Unnamed')
      template_logger.info "Rendering template '#{@template_name}'"
      raise ::Foreman::Exception.new(N_("Template '%s' is either missing or has an invalid organization or location"), @template_name) if template.nil?
      content = template.respond_to?(:template) ? template.template : template
      allowed_variables = allowed_variables_mapping(ALLOWED_VARIABLES)
      render_safe content, ALLOWED_HELPERS, allowed_variables
    end

    def unattended_render_to_temp_file(content, prefix = id.to_s, options = {})
      file = ""
      Tempfile.open(prefix, Rails.root.join('tmp')) do |f|
        f.print(unattended_render(content))
        f.flush
        f.chmod options[:mode] if options[:mode]
        file = f
      end
      file
    end

    # can be used to load additional variable relevant for give pxe type, requires @host to be present
    def load_template_vars
      # load the os family default variables
      if @host.operatingsystem.respond_to?(:pxe_type)
        send "#{@host.operatingsystem.pxe_type}_attributes"
        pxe_config
      end

      @provisioning_type = @host.is_a?(Hostgroup) ? 'hostgroup' : 'host'

      # force static network configuration if static http parameter is defined, in the future this needs to go into the GUI
      @static = !params[:static].empty?

      # this is sent by the proxy when the templates feature is enabled
      # and is needed to direct the host to the correct url. without it, we increase
      # latency by requesting the correct url directly from the proxy.
      @template_url = params['url']
    end

    private

    # takes variable names array and loads instance variables with the same name like this
    # { :name => @name, :another => @another }
    def allowed_variables_mapping(variable_names)
      variable_names.reduce({}) do |mapping, var|
        mapping.update(var => instance_variable_get("@#{var}"))
      end
    end

    def alterator_attributes
      @mediapath   = @host.operatingsystem.mediumpath @host
      @mediaserver = URI(@mediapath).host
      @metadata    = params[:metadata].to_s
    end

    def jumpstart_attributes
      if @host.operatingsystem.supports_image && @host.use_image
        @install_type     = "flash_install"
        # We have an individual override for the host's image file
        @archive_location = @host.image_file ? @host.image_file : @host.default_image_file
      else
        @install_type = "initial_install"
        @system_type  = "standalone"
        @cluster      = "SUNWCreq"
        @packages     = "SUNWgzip"
        @locale       = "C"
      end
      @disk = @host.diskLayout if @host.disk.present? || @host.ptable.present?
    end

    def kickstart_attributes
      @dynamic   = @host.diskLayout =~ /^#Dynamic/ if (@host.respond_to?(:disk) && @host.disk.present?) || @host.ptable.present?
      @arch      = @host.architecture.name
      @osver     = @host.operatingsystem.major.to_i
      @mediapath = @host.operatingsystem.mediumpath @host if @host.medium
      @repos     = @host.operatingsystem.repos @host
    end

    def preseed_attributes
      if @host.operatingsystem && @host.medium && @host.architecture
        @preseed_path   = @host.operatingsystem.preseed_path   @host
        @preseed_server = @host.operatingsystem.preseed_server @host
      end
    end

    def yast_attributes
      @dynamic   = @host.diskLayout =~ /^#Dynamic/ if (@host.respond_to?(:disk) && @host.disk.present?) || @host.ptable.present?
      @mediapath = @host.operatingsystem.mediumpath @host
    end

    def coreos_attributes
      @mediapath = @host.operatingsystem.mediumpath @host
    end

    def aif_attributes
      @mediapath = @host.operatingsystem.mediumpath @host
    end

    def memdisk_attributes
      @mediapath = @host.operatingsystem.mediumpath @host
    end

    def ZTP_attributes
      @mediapath = @host.operatingsystem.mediumpath @host
    end

    def waik_attributes
    end

    def xenserver_attributes
      @mediapath = @host.operatingsystem.mediumpath @host
      @xen = @host.operatingsystem.xen @host.arch
    end

    def pxe_config
      @kernel = @host.operatingsystem.kernel @host.arch
      @initrd = @host.operatingsystem.initrd @host.arch
    end
  end
end
