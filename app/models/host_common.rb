#Common methods between host and hostgroup
# mostly for template rendering consistency
module HostCommon

  # Returns a url pointing to boot file
  def url_for_boot file
    "#{os.medium_uri(self)}/#{os.url_for_boot(file)}"
  end

  # no need to store anything in the db if the entry is plain "puppet"
  def puppetmaster
    read_attribute(:puppetmaster) || SETTINGS[:puppet_server] || "puppet"
  end

  def puppetmaster=(pm)
    write_attribute(:puppetmaster, pm == (SETTINGS[:puppet_server] || "puppet") ? nil : pm)
  end

end
