require 'tempfile'

module Foreman
  module Renderer

    ALLOWED_HELPERS = [ :foreman_url, :grub_pass, :snippet, :snippets,
                        :snippet_if_exists, :ks_console, :root_pass,
                        :multiboot, :jumpstart_path, :install_path, :miniroot,
                        :media_path, :param_true?, :param_false?, :match, :indent ]

    ALLOWED_VARIABLES = [ :arch, :host, :osver, :mediapath, :mediaserver, :static,
                          :repos, :dynamic, :kernel, :initrd,
                          :preseed_server, :preseed_path, :provisioning_type ]


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

      url_for :only_path => false, :controller => "/unattended", :action => action,
              :protocol  => protocol, :host => host, :port => port,
              :token     => (@host.token.value unless @host.token.nil?)
    end

    # provide embedded snippets support as simple erb templates
    def snippets(file)
      if ConfigTemplate.where(:name => file, :snippet => true).empty?
        render :partial => "unattended/snippets/#{file}"
      else
        return snippet(file.gsub(/^_/, ""))
      end
    end

    def snippet(name, options = {})
      if (template = ConfigTemplate.where(:name => name, :snippet => true).first)
        logger.debug "rendering snippet #{template.name}"
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
      return unless block_given? && text=yield.to_s
      prefix = " " * count
      prefix + text.gsub(/\n/, "\n#{prefix}")
    end

    def unattended_render(template, template_name = nil)
      content = template.respond_to?(:template) ? template.template : template
      template_name ||= template.respond_to?(:name) ? template.name : 'Unnamed'
      allowed_variables = ALLOWED_VARIABLES.reduce({}) do |mapping, var|
         mapping.update(var => instance_variable_get("@#{var}"))
      end
      allowed_variables[:template_name] = template_name
      render_safe content, ALLOWED_HELPERS, allowed_variables
    end
    alias_method :pxe_render, :unattended_render

    def unattended_render_to_temp_file(content, prefix = id.to_s, options = {})
      file = ""
      Tempfile.open(prefix, Rails.root.join('tmp') ) do |f|
        f.print(unattended_render(content))
        f.flush
        f.chmod options[:mode] if options[:mode]
        file = f
      end
      file
    end

  end
end
