module UnattendedHelper
  # outputs kickstart installation media based on the media type (NFS or URL)
  # it also convert the $arch string to the current host architecture

  def mediapath
    server, dir  = @host.media.path.split(":")
    dir.gsub!('$arch',@host.architecture.name)

    return server =~ /^(h|f)t*p$/ ? "url --url #{server+":"+dir}" : "nfs --server #{server} --dir #{dir}"
  end

  def preseed_server
    @host.media.path.match('^(\w+):\/\/((\w|\.)+)((\w|\/)+)$')[2]
  end

  #TODO: rethink of a more generic way
  def preseed_path
    @host.media.path.match('^(\w+):\/\/((\w|\.)+)((\w|\/)+)$')[4]
  end

  def yumrepo
    if @repo
      "--enablerepo #{repo}"
    end
  end

  def epel
    if @osver == 5 or 4
      "su -c 'rpm -Uvh http://download.fedora.redhat.com/pub/epel/#{@osver}/#{@arch}/epel-release-#{@host.os.to_version}.noarch.rpm'"
    else
      ""
    end
  end

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
    render :partial => "unattended/snippets/#{file}"
  end

end
