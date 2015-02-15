module ComputeResourcesVmsHelper

  def vm_power_actions(host, vm)
    button_group(
      if vm
        html_opts = vm.ready? ? {:confirm => _('Are you sure?'), :class => "btn btn-danger"} : {:class => "btn btn-success"}
        link_to_if_authorized _("Power%s") % state(vm.ready?), hash_for_power_host_path(:power_action => vm.ready? ? :stop : :start).merge(:auth_object => host, :permission => 'power_hosts'),
        html_opts.merge(:method => :put)
      else
        link_to(_("Unknown Power State"), '#', :disabled => true, :class => "btn btn-warning")
      end
    )
  end

  def vm_console(host, vm)
    if vm && vm.ready?
      link_to_if_authorized(_("Console"), hash_for_console_host_path().merge(:auth_object => host, :permission => 'console_hosts'),
                            { :class => "btn btn-info" })
    else
      link_to(_("Console"), '#', {:disabled=> true, :class => "btn btn-info"})
    end
  end

  # little helper to help show VM properties
  def prop(method, title = nil)
    content_tag :tr do
      result = content_tag(:td) do
        title || method.to_s.humanize
      end
      result += content_tag(:td) do
        value = @vm.send(method) rescue nil
        case value
        when Array
          #TODO in 4.0 #try will return nil if the method doesn't exist (instead of raising NoMethodError)
          # we can drop rescues then.
          value.map{|v| (v.try(:name) rescue nil) || (v.try(:to_s) rescue nil) || v}.to_sentence
        when Fog::Time, Time
          _("%s ago") % time_ago_in_words(value)
        when nil
          _("N/A")
        else
          method == :memory ? number_to_human_size(value) : value.to_s
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
      :subject     => console[:subject],
      :title       => _("%s - Press Shift-F12 to release the cursor.") % console[:name]
    ) if supports_spice_xpi?
    options.merge!(
      :ca_cert     => URI.escape(console[:ca_cert])
    ) if console[:ca_cert].present?
    options
  end

  def libvirt_networks(compute)
    networks   = compute.networks
    select     = []
    select << [_('Physical (Bridge)'), :bridge]
    select << [_('Virtual (NAT)'), :network] if networks.any?
    select
  end

  def vsphere_datastores(compute)
    compute.datastores.map do |ds|
      [
        ds.freespace && ds.capacity ?
          "#{ds.name} (#{_('free')}: #{number_to_human_size(ds.freespace)}, #{_('prov')}: #{number_to_human_size(ds.capacity + (ds.uncommitted || 0) - ds.freespace)}, #{_('total')}: #{number_to_human_size(ds.capacity)})" :
          ds.name,
        ds.name
      ]
    end
  end

  def available_actions(vm, authorizer = nil)
    case vm
    when Fog::Compute::OpenStack::Server
      openstack_available_actions(vm, authorizer)
    else
      default_available_actions(vm, authorizer)
    end
  end

  def openstack_available_actions(vm, authorizer = nil)
    actions = []
    if vm.state == 'ACTIVE'
      actions << vm_power_action(vm, authorizer)
      actions << vm_pause_action(vm, authorizer)
    elsif vm.state == 'PAUSED'
      actions << vm_pause_action(vm, authorizer)
    else
      actions << vm_power_action(vm, authorizer)
    end

    actions << display_delete_if_authorized(hash_for_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity).merge(:auth_object => @compute_resource, :authorizer => authorizer))
  end

  def default_available_actions(vm, authorizer = nil)
    [vm_power_action(vm, authorizer),
     display_delete_if_authorized(hash_for_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity).merge(:auth_object => @compute_resource, :authorizer => authorizer))]
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

  def compute_object_vpc_id(form)
    form.object.network_interfaces.try(:first).try(:[], "vpcId")
  end

  def security_groups_for_vpc(security_groups, vpc_id)
    security_groups.map{ |sg| [sg.name, sg.group_id] if sg.vpc_id == vpc_id}.compact
  end

  def show_vm_name?
    controller_name != 'hosts' && controller_name != 'compute_attributes'
  end

  def new_host?(host)
    host.try(:new_record?)
  end

end
