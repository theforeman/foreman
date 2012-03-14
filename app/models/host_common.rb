#Common methods between host and hostgroup
# mostly for template rendering consistency
module HostCommon
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      belongs_to :architecture
      belongs_to :environment
      belongs_to :operatingsystem
      belongs_to :medium
      belongs_to :ptable
      belongs_to :puppet_proxy,    :class_name => "SmartProxy"
      belongs_to :puppet_ca_proxy, :class_name => "SmartProxy"
      belongs_to :domain
      belongs_to :subnet

      before_save :check_puppet_ca_proxy_is_required?
    end
  end

  module InstanceMethods
    # Returns a url pointing to boot file
    def url_for_boot file
      "#{os.medium_uri(self)}/#{os.url_for_boot(file)}"
    end

    def puppetca?
      !!(puppet_ca_proxy and puppet_ca_proxy.url.present?)
    end

    # no need to store anything in the db if the entry is plain "puppet"
    # If the system is using smart proxies and the user has run the smartproxy:migrate task
    # then the puppetmaster functions handle smart proxy objects
    def puppetmaster
      puppet_proxy.to_s
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
      p = pass.empty? ? nil : (pass =~ /^\$1\$foreman\$.*/ ? pass : pass.crypt("$1$foreman$"))
      write_attribute(:root_pass, p)
    end

    private

    # fall back to our puppet proxy in case our puppet ca is not defined/used.
    def check_puppet_ca_proxy_is_required?
      return true if puppet_ca_proxy_id.present? or puppet_proxy_id.blank?
      if puppet_proxy.features.include?("Puppet CA")
        self.puppet_ca_proxy ||= puppet_proxy
      end
    rescue
      true # we don't want to break anything, so just skipping.
    end
  end
end
