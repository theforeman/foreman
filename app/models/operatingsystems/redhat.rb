class Redhat < Operatingsystem
  PXEFILES = {:kernel => "vmlinuz", :initrd => "initrd.img"}

  # outputs kickstart installation medium based on the medium type (NFS or URL)
  # it also convert the $arch string to the current host architecture
  def mediumpath(medium_provider)
    uri = medium_provider.medium_uri

    case uri.scheme
      when 'http', 'https', 'ftp'
        "url --url #{uri}"
      else
        server = uri.select(:host, :port).compact.join(':')
        dir    = uri.select(:path, :query).compact.join('?')
        "nfs --server #{server} --dir #{dir}"
    end
  end

  def available_loaders
    self.class.all_loaders
  end

  # The PXE type to use when generating actions and evaluating attributes. jumpstart, kickstart and preseed are currently supported.
  def pxe_type
    "kickstart"
  end

  def pxedir(medium_provider = nil)
    if medium_provider.try(:architecture).try(:name) =~ /^ppc64/
      "ppc/ppc64"
    else
      "images/pxeboot"
    end
  end

  def display_family
    "Red Hat"
  end

  def shorten_description(description)
    return "" if description.blank?
    s = description.dup
    s.gsub!('Red Hat Enterprise Linux', 'RHEL')
    s.gsub!('release', '')
    s.gsub!(/\(.+?\)/, '')
    s.squeeze! " "
    s.strip!
    s.presence || description
  end

  def pxe_kernel_options(params)
    options = super
    options << "modprobe.blacklist=#{params['blacklist'].delete(' ')}" if params['blacklist']
    options
  end
end
