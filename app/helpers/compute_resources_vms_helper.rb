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
    select << [_('Physical (Bridge)'), :bridge]
    select << [_('Virtual (NAT)'), :network] if networks.any?
    select
  end

  def vpc_security_group_hash(security_groups)
    vpc_sg_hash = Hash.new
    security_groups.each{ |sg|
      vpc_id = sg.vpc_id || 'ec2'
      ( vpc_sg_hash[vpc_id] ||= []) << {:group_name => sg.name, :group_id => sg.group_id}
    }
    vpc_sg_hash
  end

  def subnet_vpc_hash(subnets)
    subnet_vpc_hash = Hash.new
    subnets.each{ |sub| subnet_vpc_hash[sub.subnet_id] = {:vpc_id =>sub.vpc_id, :subnet_name => sub.tag_set["Name"] || sub.subnet_id} }
    subnet_vpc_hash
  end

end
