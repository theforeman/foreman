module ComputeResourcesVmsHelper

  # little helper to help show VM properties
  def prop method, title = nil
    content_tag :tr do
      result = content_tag :td do
        title || method.to_s.humanize
      end
      result += content_tag :td do
        value = @vm.send(method) rescue nil
        case value
        when Array
          value.map{|v| v.try(:name) || v.try(:to_s) || v}.to_sentence
        when Fog::Time, Time
          _("%s ago") % time_ago_in_words(value)
        when nil
            _("N/A")
        else
          value.to_s
        end
      end
      result
    end
  end

  def supports_spice_xpi?
    user_agent = request.env['HTTP_USER_AGENT']
    user_agent =~ /linux/i && user_agent =~ /firefox/i
  end

  def spice_data_attributes(console)
    options = {
      :port     => console[:proxy_port],
      :password => console[:password]
    }
    options.merge!(
      :address     => console[:address],
      :secure_port => console[:secure_port],
      :ca_cert     => URI.escape(console[:ca_cert]),
      :title       => _("%s - Press Shift-F12 to release the cursor.") % console[:name]
    ) if supports_spice_xpi?
    options
  end

  def libvirt_networks(compute)
    networks   = compute.networks
    interfaces = compute.interfaces
    select     = []
    select << _('Physical (Bridge)') if interfaces.any?
    select << _('Virtual (NAT)')     if networks.any?
    select
  end

  def hide_libvirt_network(networks, interfaces)
    return true  if interfaces.empty?
    return true  if interfaces.any? && networks.any?
    return false if interfaces.any? && networks.empty?
    true
  end

end
