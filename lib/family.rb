# Adds operatingsystem family behaviour to the Operatingsystem class
# The variant is calculated at run-time
require 'ostruct'
module Family
  # NEVER, EVER reorder this list. Additions are allowed but offsets are encoded in the database
  FAMILIES  = [:Debian, :RedHat, :Solaris]
  def family
    FAMILIES[family_id]
  end

  def self.families_as_collection
    FAMILIES.map{|e| OpenStruct.new(:name => e, :value => FAMILIES.index(e)) }
  end

  module Debian
    include Family

    def preseed_server media
      media.path.match('^(\w+):\/\/((\w|\.)+)((\w|\/)+)$')[2]
    end

    #TODO: rethink of a more generic way
    def preseed_path media
      media.path.match('^(\w+):\/\/((\w|\.)+)((\w|\/)+)$')[4]
    end
  end

  module RedHat
    include Family
    # outputs kickstart installation media based on the media type (NFS or URL)
    # it also convert the $arch string to the current host architecture
    def mediapath host
      server, dir  = host.media.path.split(":")
      dir.gsub!('$arch',host.architecture.name)

      return server =~ /^(h|f)t*p$/ ? "url --url #{server+":"+dir}" : "nfs --server #{server} --dir #{dir}"
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
