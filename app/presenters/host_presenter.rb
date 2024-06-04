class HostPresenter
  def self.display_name(name)
    return name if Setting[:display_fqdn_for_hosts]
    (name || '').split('.')[0]
  end
end
