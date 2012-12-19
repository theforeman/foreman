require 'tempfile'

module Foreman
  module Renderer
    def render_safe template, allowed_methods = [], allowed_vars = {}

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
      url_for :only_path => false, :controller => "/unattended", :action => action,
              :host      => (Setting[:foreman_url] unless Setting[:foreman_url].blank?),
              :protocol  => 'http',
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

    def snippet name
      if (template = ConfigTemplate.where(:name => name, :snippet => true).first)
        logger.debug "rendering snippet #{template.name}"
        begin
          return unattended_render(template.template)
        rescue Exception => exc
          raise "The snippet '#{name}' threw an error: #{exc}"
        end
      else
        raise "The specified snippet '#{name}' does not exist, or is not a snippet."
      end
    end

    def unattended_render template
      allowed_helpers   = [ :foreman_url, :grub_pass, :snippet, :snippets, :ks_console, :root_pass, :multiboot, :jumpstart_path, :install_path,
                            :miniroot, :media_path]
      allowed_variables = ({:arch => @arch, :host => @host, :osver => @osver, :mediapath => @mediapath, :static => @static,
                           :yumrepo => @yumrepo, :dynamic => @dynamic, :epel => @epel, :kernel => @kernel, :initrd => @initrd,
                           :preseed_server => @preseed_server, :preseed_path => @preseed_path })
      render_safe template, allowed_helpers, allowed_variables
    end
    alias_method :pxe_render, :unattended_render

    def unattended_render_to_temp_file content, prefix = id, options = {}
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
