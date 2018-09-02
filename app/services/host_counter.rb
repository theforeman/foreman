class HostCounter
  def initialize(association)
    @association = association
  end

  def [](instance)
    counted_hosts[instance&.id] || 0
  end

  def hosts_count
    counted_hosts
  end

  private

  def counted_hosts
    hosts_scope = Host::Managed.reorder('')
    case @association.to_s
    when 'organization', 'location'
      # If we are on /organizations or /locations, this allows to display the
      # count for hosts not in the current organization & location.
      hosts_scope = hosts_scope.unscoped
    when 'subnet'
      hosts_scope = hosts_scope.joins(:primary_interface)
    end
    @counted_hosts ||= hosts_scope.authorized(:view_hosts).group("#{@association}_id").count
  end
end
