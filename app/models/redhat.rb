class Redhat < Operatingsystem
  # outputs kickstart installation media based on the media type (NFS or URL)
  # it also convert the $arch string to the current host architecture
  def mediapath host
    uri = media_uri(host)
    server = uri.select(:host, :port).compact.join(':')
    dir = uri.select(:path, :query).compact.join('?') unless uri.scheme == 'ftp'

    case uri.scheme
      when 'http', 'https', 'ftp'
         "url --url #{uri.to_s}"
      else
        "nfs --server #{server} --dir #{dir}"
    end
  end

  # installs the epel repo
  def epel host
    epel_url = "http://download.fedora.redhat.com/pub/epel/$major/$arch/epel-release-$os.noarch.rpm"

    case host.operatingsystem.major
    when "4"
      epel_url.gsub!("$os","4-9")
    when "5"
      epel_url.gsub!("$os","5-3")
    when "6"
       epel_url.gsub!("$os","6-1").
         gsub!("/pub/epel/","/pub/epel/beta/") # workaround for hardcoded beta in url, should be remove once RH6 is released
    else
      return ""
    end
    return "su -c 'rpm -Uvh #{media_uri(host, epel_url)}'"
  end

  def yumrepo host
    if host.respond_to? :yumrepo
      "--enablerepo #{repo}"
    end
  end

end