module UnattendedHelper

  def ks_console
    (@port and @baud) ? "console=ttyS#{@port},#{@baud}": ""
  end

  def grub_pass
    @grub ? "--md5pass=#{@host.root_pass}": ""
  end

  def root_pass
    @host.root_pass
  end

  #returns the URL for Foreman Built status (when a host has finished the OS installation)
  def foreman_url(action = "built")
    url_for :only_path => false, :controller => "unattended", :action => action
  end

  # provide embedded snippets support as simple erb templates
  def snippets(file)
    if (s=snippet(file.gsub(/^_/,"")))
      return s
    else
      render :partial => "unattended/snippets/#{file}"
    end
  end

  def snippet name
    if template = ConfigTemplate.name_eq(name).snippet_eq(true).first
      logger.debug "rendering snippet #{template.name}"
      return render :inline => template.template
    end
  rescue
    false
  end

  def render_sandbox template
    allowed_helpers   = [ :foreman_url, :grub_pass, :snippet, :snippets, :ks_console, :root_pass ]
    allowed_variables = ({:arch => @arch, :host => @host, :osver => @osver, :mediapath => @mediapath, :static => @static,
                         :yumrepo => @yumrepo, :dynamic => @dynamic, :epel => @epel,
                         :preseed_server => @preseed_server, :preseed_path => @preseed_path })

    box = Safemode::Box.new self, allowed_helpers
    box.eval(ERB.new(template, nil, '-').src, allowed_variables)
  end

end
