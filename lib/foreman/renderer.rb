module Foreman
  module Renderer
    def render_safe template, allowed_methods = [], allowed_vars = {}

      if Setting[:safemode_render]
        box = Safemode::Box.new self, allowed_methods
        box.eval(ERB.new(template, nil, '-').src, allowed_vars)
      else
        ERB.new(template, nil, '-').result(binding)
      end
    end
    #returns the URL for Foreman Built status (when a host has finished the OS installation)
    def foreman_url(action = "built")
      url_for :only_path => false, :controller => "unattended", :action => action
    end

    # provide embedded snippets support as simple erb templates
    def snippets(file)
      unless ConfigTemplate.name_eq(file).snippet_eq(true).empty?
        return snippet(file.gsub(/^_/,""))
      else
        render :partial => "unattended/snippets/#{file}"
      end
    end

    def snippet name
      if template = ConfigTemplate.name_eq(name).snippet_eq(true).first
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
                            :miniroot]
      allowed_variables = ({:arch => @arch, :host => @host, :osver => @osver, :mediapath => @mediapath, :static => @static,
                           :yumrepo => @yumrepo, :dynamic => @dynamic, :epel => @epel, :kernel => @kernel, :initrd => @initrd,
                           :preseed_server => @preseed_server, :preseed_path => @preseed_path })
      render_safe template, allowed_helpers, allowed_variables
    end
    alias_method :pxe_render, :unattended_render
  end
end
