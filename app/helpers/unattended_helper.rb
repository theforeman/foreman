module UnattendedHelper
  # outputs kickstart installation media based on the media type (NFS or URL)
  # it also convert the $arch string to the current host architecture
  #
  
  def mediapath
    server, dir  = @host.media.path.split(":")
    dir.gsub!('$arch',@host.architecture.name)

    return server =~ /^(h|f)t*p$/ ? "url --url #{server+":"+dir}" : "nfs --server #{server} --dir #{dir}"
  end

  def yumrepo
    if @repo
      "--enablerepo #{repo}"
    end
  end
  def ca_pubkey
    unless $settings[:CAPubKey].nil?
      return    "# We need a mechanism for propagating the CA root certificate.
# We use kickstart because this needs to be in place before
# puppet will work.

# This is the CA for vihla005. It is self signed.
echo \"#{$settings[:CAPubKey]}\" >> /var/lib/puppet/ssl/certs/ca.pem
sync
count=`grep -- \"--END\" /var/lib/puppet/ssl/certs/ca.pem|wc -l`
echo \"Updated the certificate chain. There are now $count certificates\"
      "
    end
    return ""
  end
end
