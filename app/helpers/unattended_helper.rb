module UnattendedHelper

  def ca_pubkey
    #TODO: replace hardcoded dirs into puppet variables
    unless SETTINGS[:CAPubKey].nil?
      "echo \"#{SETTINGS[:CAPubKey]}\" >> /var/lib/puppet/ssl/certs/ca.pem
count=`grep -c -- \"--END\" /var/lib/puppet/ssl/certs/ca.pem`
echo \"Updated the certificate chain. There are now $count certificates\""
    end
    return ""
  end

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
     box = Safemode::Box.new self, [:foreman_url, :grub_pass, :snippets, :ks_console, :root_pass, :ca_pubkey]
     box.eval(ERB.new(template, nil, '-').src, {:host=>@host, :osver=>@osver, :mediapath=>@mediapath, :static=>@static, :yumrepo=>@yumrepo, :dynamic=>@dynamic})
  end

end
