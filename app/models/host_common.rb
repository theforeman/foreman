#Common methods between host and hostgroup
# mostly for template rendering consistency
module HostCommon
  def self.included(base)
    base.send :include, InstanceMethods
    base.class_eval do
      validates_format_of   :puppetmaster_name, :with => /^puppet$|^.*\..+\S$/, :allow_blank => true, :message => "The puppetmaster may be 'puppet' or the fully qualified hostname"
      validates_presence_of :puppetmaster
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
        read_attribute(:puppetmaster_name) || SETTINGS[:puppet_server] || "puppet"
      end
    end

    def puppetmaster=(pm)
      if puppetca?
        write_attribute(:puppetproxy_id, pm.id)
      else
        write_attribute(:puppetmaster_name, pm == (SETTINGS[:puppet_server] || "puppet") ? nil : pm)
      end
    end

   private

   def normalize_puppetmaster


   end

  end
end
