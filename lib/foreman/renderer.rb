require 'tempfile'

module Foreman
  module Renderer
    class RenderingError < Foreman::Exception; end
    class SyntaxError < RenderingError; end
    class WrongSubnetError < RenderingError; end
    class HostUnknown < RenderingError; end
    class HostParamUndefined < RenderingError; end
    class HostENCParamUndefined < RenderingError; end

    include ::Foreman::ForemanUrlRenderer

    ALLOWED_GENERIC_HELPERS ||= [ :foreman_url, :snippet, :snippets, :snippet_if_exists, :indent, :foreman_server_fqdn,
                                  :foreman_server_url, :log_debug, :log_info, :log_warn, :log_error, :log_fatal, :template_name, :dns_lookup,
                                  :pxe_kernel_options, :save_to_file, :subnet_param, :subnet_has_param? ]
    ALLOWED_HOST_HELPERS ||= [ :grub_pass, :ks_console, :root_pass,
                               :media_path, :match,
                               :host_param_true?, :host_param_false?,
                               :host_param, :host_param!, :host_puppet_classes, :host_enc ]

    ALLOWED_HELPERS ||= ALLOWED_GENERIC_HELPERS + ALLOWED_HOST_HELPERS

    ALLOWED_VARIABLES ||= [ :arch, :host, :osver, :mediapath, :mediaserver, :static,
                            :repos, :dynamic, :kernel, :initrd, :xen,
                            :preseed_server, :preseed_path, :provisioning_type, :template_name ]

    def template_logger
      @template_logger ||= Foreman::Logging.logger('templates')
    end

    def host_enc(*path)
      check_host
      @enc ||= @host.info.deep_dup
      return @enc if path.compact.empty?
      enc = @enc
      step = nil
      path.each { |step| enc = enc.fetch step }
      enc
    rescue KeyError
      raise(HostENCParamUndefined, _('Parameter %{name} is not set in host %{host} ENC output, resolving failed on step %{step}') % { :name => path, :step => step, :host => @host })
    end

    def host_param(param_name, default = nil)
      check_host
      @host.host_param(param_name) || default
    end

    def host_param!(param_name)
      check_host_param(param_name)
      host_param(param_name)
    end

    def host_puppet_classes
      check_host
      @host.puppetclasses
    end

    def host_param_true?(name)
      check_host
      @host.params.has_key?(name) && Foreman::Cast.to_bool(@host.params[name])
    end

    def host_param_false?(name)
      check_host
      @host.params.has_key?(name) && Foreman::Cast.to_bool(@host.params[name]) == false
    end

    def subnet_has_param?(subnet, param_name)
      validate_subnet(subnet)
      subnet.parameters.exists?(name: param_name)
    end

    def subnet_param(subnet, param_name)
      validate_subnet(subnet)
      param = subnet.parameters.where(name: param_name).first
      param.nil? ? nil : param.value
    end

    def render_safe(template, allowed_methods = [], allowed_vars = {}, scope_variables = {})
      if Setting[:safemode_render]
        box = Safemode::Box.new self, allowed_methods, template_name
        erb = ERB.new(template, nil, '-')
        box.eval(erb.src, allowed_vars.merge(scope_variables))
      else
        # we need to keep scope variables and reset them after rendering otherwise they would remain
        # after snippets are rendered in parent template scope
        kept_variables = {}
        scope_variables.each { |k,v| kept_variables[k] = instance_variable_get("@#{k}") }

        allowed_vars.merge(scope_variables).each { |k,v| instance_variable_set "@#{k}", v }
        erb = ERB.new(template, nil, '-')
        # erb allows to set location since Ruby 2.2
        erb.location = template_name, 0 if erb.respond_to?(:location=)
        result = erb.result(binding)

        scope_variables.each { |k,v| instance_variable_set "@#{k}", kept_variables[k] }
        result
      end
    rescue ::Racc::ParseError, ::SyntaxError => e
      # Racc::ParseError is raised in safe mode, SyntaxError in unsafe mode
      new_e = Foreman::Renderer::SyntaxError.new(N_("Syntax error occurred while parsing the template %{template_name}, make sure you have all ERB tags properly closed and the Ruby syntax is valid. The Ruby error: %{message}"), :template_name => template_name, :message => e.message)
      new_e.set_backtrace(e.backtrace)
      raise new_e
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
    def snippets(file, options = {})
      if Template.where(:name => file, :snippet => true).empty?
        render :partial => "unattended/snippets/#{file}"
      else
        snippet(file.gsub(/^_/, ""), options)
      end
    end

    def snippet(name, options = {})
      if (template = Template.where(:name => name, :snippet => true).first)
        begin
          return unattended_render(template, nil, options[:variables] || {})
        rescue => exc
          if exc.is_a?(::Foreman::Exception)
            raise exc
          else
            e = ::Foreman::Exception.new(N_("The snippet '%{name}' threw an error: %{exc}"), { :name => name, :exc => exc })
            e.set_backtrace exc.backtrace
            raise e
          end
        end
      else
        if options[:silent]
          nil
        else
          raise "The specified snippet '#{name}' does not exist, or is not a snippet."
        end
      end
    end

    def snippet_if_exists(name, options = {})
      snippet name, options.merge(:silent => true)
    end

    def save_to_file(filename, content)
      "cat << EOF > #{filename}\n#{content}EOF"
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
          resolver.getname(name_or_ip)
        rescue Resolv::ResolvError
          resolver.getaddress(name_or_ip)
        end
      end
    rescue => e
      log_warn "Template helper dns_lookup failed: #{e}"
      raise e
    end

    # accepts either template object or plain string
    def unattended_render(template, overridden_name = nil, scope_variables = {})
      @template_name = template.respond_to?(:name) ? template.name : (overridden_name || 'Unnamed')
      template_logger.info "Rendering template '#{@template_name}'"
      raise ::Foreman::Exception.new(N_("Template '%s' is either missing or has an invalid organization or location"), @template_name) if template.nil?
      content = template.respond_to?(:template) ? template.template : template
      allowed_variables = allowed_variables_mapping(ALLOWED_VARIABLES)
      render_safe content, ALLOWED_HELPERS, allowed_variables, scope_variables
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

    def check_host
      raise HostUnknown, _('This templates requires a host to render but none was specified') if @host.nil?
    end

    def check_host_param(name)
      check_host
      raise(HostParamUndefined, _('Parameter %{name} is not set for host %{host}') % { :name => name, :host => @host }) unless @host.params.key?(name)
    end

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
      @mediapath = @host.operatingsystem.mediumpath @host if @host.medium
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

    def validate_subnet(subnet)
      raise ::Foreman::Renderer::WrongSubnetError.new(N_("'%{object_name}' is a '%{object_class}', expected a subnet.") % { object_name: subnet.to_s, object_class: subnet.class.to_s}) unless subnet.is_a?(Subnet)
    end
  end
end
