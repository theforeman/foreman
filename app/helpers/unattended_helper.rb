module UnattendedHelper
  def mediapath
    helper =  "#{@host.media.path}/#{@host.architecture}".split(":")
    return helper[0] =~ /^(h|f)t*p$/ ? "url --url #{@host.media.path}/#{@host.architecture}" : "nfs --server #{helper[0]} --dir #{helper[1]}"
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
