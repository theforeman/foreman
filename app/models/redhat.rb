class Redhat < Operatingsystem

  PXEFILES = {:kernel => "vmlinuz", :initrd => "initrd.img"}

  # outputs kickstart installation medium based on the medium type (NFS or URL)
  # it also convert the $arch string to the current host architecture
  def mediumpath host
    uri    = medium_uri(host)

    case uri.scheme
      when 'http', 'https', 'ftp'
         "url --url #{uri}"
      else
        server = uri.select(:host, :port).compact.join(':')
        dir    = uri.select(:path, :query).compact.join('?')
        "nfs --server #{server} --dir #{dir}"
    end
  end

  # installs the epel repo
  def epel host
    epel_url = "http://download.fedoraproject.org/pub/epel/$major/$arch/epel-release-$os.noarch.rpm"

    case host.operatingsystem.major
    when "4"
      epel_url.gsub!("$os","4-10")
    when "5"
      epel_url.gsub!("$os","5-4")
    when "6"
       epel_url.gsub!("$os","6-5")
    else
      return ""
    end
    "su -c 'rpm -Uvh #{medium_uri(host, epel_url)}'"
  end

  def yumrepo host
    if host.respond_to? :yumrepo
      "--enablerepo #{repo}"
    end
  end

  # Override the class representation, as this breaks many rails helpers
  def class
    Operatingsystem
  end

  # The PXE type to use when generating actions and evaluating attributes. jumpstart, kickstart and preseed are currently supported.
  def pxe_type
    "kickstart"
  end

  def pxedir
    "images/pxeboot"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

end
