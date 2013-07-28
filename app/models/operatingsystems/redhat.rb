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
