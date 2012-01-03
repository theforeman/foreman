#Common methods between host and hostgroup
# mostly for template rendering consistency
module HostCommon
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      validates_format_of   :puppetmaster_name, :with => /^puppet$|^.*\..+\S$/, :allow_blank => true, :message => "The puppetmaster may be 'puppet' or the fully qualified hostname"
      validates_presence_of :puppetmaster
      belongs_to :architecture
      belongs_to :environment
      belongs_to :operatingsystem
      belongs_to :medium
      belongs_to :ptable
      belongs_to :puppetproxy, :class_name => "SmartProxy"
      belongs_to :domain
      belongs_to :subnet
    end
  end

  module InstanceMethods
    # Returns a url pointing to boot file
    def url_for_boot file
      "#{os.medium_uri(self)}/#{os.url_for_boot(file)}"
    end

    def puppetca?
      (!puppetproxy_id.nil? and !puppetproxy.url.empty?)
    end

    # no need to store anything in the db if the entry is plain "puppet"
    # If the system is using smart proxies and the user has run the smartproxy:migrate task
    # then the puppetmaster functions handle smart proxy objects
    def puppetmaster
      if puppetca?
        SmartProxy.find(read_attribute(:puppetproxy_id))
      else
        read_attribute(:puppetmaster_name) || Setting[:puppet_server]
      end
    end

    def puppetmaster=(pm)
      if puppetca?
        write_attribute(:puppetproxy_id, pm.id)
      else
        write_attribute(:puppetmaster_name, pm == (Setting[:puppet_server]) ? nil : pm)
      end
    end

    # no need to store anything in the db if the password is our default
    def root_pass
      read_attribute(:root_pass) || Setting[:root_pass]
    end

    # If the host/hostgroup has a medium then use the path from there
    # Else if the host/hostgroup's operatingsystem has only one media then use the image_path from that as this is automatically displayed when there is only one item
    # Else we cannot provide a default and it is cut and paste time
    def default_image_file
      return "" unless operatingsystem and operatingsystem.supports_image
      if medium
        nfs_path = medium.try :image_path
        if operatingsystem.try(:media) and operatingsystem.media.size == 1
          nfs_path ||= operatingsystem.media.first.image_path
        end
        # We encode the hw_model into the image file name as not all Sparc flashes can contain all possible hw_models. The user can always
        # edit it if required or use symlinks if they prefer.
        hw_model = model.try :hardware_model if defined?(model_id)
        operatingsystem.interpolate_medium_vars(nfs_path, architecture.name, operatingsystem) +\
          "#{operatingsystem.file_prefix}.#{architecture}#{hw_model.empty? ? "" : "." + hw_model.downcase}.#{operatingsystem.image_extension}"
      else
        ""
      end
    end

    def image_file= file
      # We only save a value into the image_file field if the value is not the default path, (which was placed in the entry when it was displayed,)
      # and it is not a directory, (ends in /)
      value = ( (default_image_file == file) or (file =~ /\/$/) or file == "") ? nil : file
      write_attribute :image_file, value
    end

    def image_file
      super || default_image_file
    end

    # make sure we store an encrypted copy of the password in the database
    # this password can be use as is in a unix system
    def root_pass=(pass)
      return if pass.empty?
      p = pass =~ /^\$1\$foreman\$.*/ ? pass : pass.crypt("$1$foreman$")
      write_attribute(:root_pass, p)
    end

  end
end
