# Adds operatingsystem family behaviour to the Operatingsystem class
# The variant is calculated at run-time
require 'ostruct'
require 'uri'

module Family
  # NEVER, EVER reorder this list. Additions are allowed but offsets are encoded in the database
  FAMILIES  = [:Debian, :RedHat, :Solaris]
  def family
    FAMILIES[family_id]
  end

  def self.families_as_collection
    FAMILIES.map{|e| OpenStruct.new(:name => e, :value => FAMILIES.index(e)) }
  end

  def media_uri host
    URI.parse(host.media.path.gsub('$arch',host.architecture.name).
                              gsub('$major', host.os.major).
                              gsub('$minor', host.os.minor).
                              gsub('$version', [ host.os.major, host.os.minor ].compact.join('.'))
    ).normalize
  end

  module Debian
    include Family

    def preseed_server host
      media_uri(host).select(:host, :port).compact.join(':')
    end

    def preseed_path host
      media_uri(host).select(:path, :query).compact.join('?')
    end
  end

  module RedHat
    include Family
    # outputs kickstart installation media based on the media type (NFS or URL)
    # it also convert the $arch string to the current host architecture
    def mediapath host
      uri = media_uri(host)
      server = uri.select(:host, :port).compact.join(':')
      dir = uri.select(:path, :query).compact.join('?')

      case uri.scheme
        when 'http', 'https', 'ftp'
           "url --url #{uri.to_s}"
        else
          "nfs --server #{server} --dir #{dir}"
      end
    end

    def epel arch
      ["4","5"].include?(major) ? "su -c 'rpm -Uvh http://download.fedora.redhat.com/pub/epel/#{major}/#{arch}/epel-release-#{to_version}.noarch.rpm'" : ""
    end

    def yumrepo host
      if host.respond_to? :yumrepo
        "--enablerepo #{repo}"
      end
    end

  end

  module Solaris
    include Family
  end
end
