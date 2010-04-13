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
    render :partial => "unattended/snippets/#{file}"
  end

end
