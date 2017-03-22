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
          value.map{|v| v.try(:name) || v.try(:to_s) || v}.to_sentence
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
    compute.datastores.map { |datastore| [datastore_stats(datastore), datastore.name] }
  end

  def vsphere_networks(compute_resource)
    networks = compute_resource.networks
    networks.map do |net|
      net_id = net.id
      net_name = net.name
      net_name += " (#{net.virtualswitch})" if net.virtualswitch
      [net_id, net_name]
    end
  end

  def datastore_stats(datastore)
    return datastore.name unless datastore.freespace && datastore.capacity
    "#{datastore.name} (#{_('free')}: #{number_to_human_size(datastore.freespace)}, #{_('prov')}: #{number_to_human_size(datastore.capacity + (datastore.uncommitted || 0) - datastore.freespace)}, #{_('total')}: #{number_to_human_size(datastore.capacity)})"
  end

  def vsphere_storage_pods(compute)
    compute.storage_pods.map { |pod| [storage_pod_stats(pod), pod.name] }
  end

  def storage_pod_stats(pod)
    "#{pod.name} (#{_('free')}: #{number_to_human_size(pod.freespace)}, #{_('prov')}: #{number_to_human_size(pod.capacity - pod.freespace)}, #{_('total')}: #{number_to_human_size(pod.capacity)})"
  end

  def available_actions(vm, authorizer = nil)
    return default_available_actions(vm, authorizer) unless defined? Fog::Compute::OpenStack::Server
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

    actions << vm_import_action(vm)
    actions << vm_delete_action(vm, authorizer)
  end

  def default_available_actions(vm, authorizer = nil)
    [vm_power_action(vm, authorizer), vm_delete_action(vm, authorizer)]
  end

  def vpc_security_group_hash(security_groups)
    vpc_sg_hash = {}
    security_groups.each do |sg|
      vpc_id = sg.vpc_id || 'ec2'
      (vpc_sg_hash[vpc_id] ||= []) << {:group_name => sg.name, :group_id => sg.group_id}
    end
    vpc_sg_hash
  end

  def subnet_vpc_hash(subnets)
    subnet_vpc_hash = {}
    subnets.each{ |sub| subnet_vpc_hash[sub.subnet_id] = {:vpc_id =>sub.vpc_id, :subnet_name => sub.tag_set["Name"] || sub.subnet_id} }
    subnet_vpc_hash
  end

  def security_groups_selectable(compute_resource, form)
    all_security_groups = compute_resource.security_groups.all
    subnet_vpc_hash = subnet_vpc_hash(compute_resource.subnets)
    vpc_sg_hash = vpc_security_group_hash(all_security_groups)
    selected_subnet = form.object.subnet_id

    vpc_id = selected_subnet.present? && subnet_vpc_hash[selected_subnet][:vpc_id]
    groups = security_groups_for_vpc(all_security_groups, vpc_id).presence ||
             security_group_not_selected(subnet_vpc_hash, vpc_sg_hash, vpc_id)

    [groups, vpc_sg_hash, subnet_vpc_hash]
  end

  def security_groups_for_vpc(security_groups, vpc_id)
    security_groups.map{ |sg| [sg.name, sg.group_id] if sg.vpc_id == vpc_id }.compact
  end

  def security_group_not_selected(subnet_vpc_hash, vpc_sg_hash, vpc_id)
    return [] if vpc_id.blank?
    vpc_sg_hash[vpc_id].map do |vpc_sg|
      ["#{vpc_sg[:group_name]} - #{selected_subnet}", vpc_sg[:group_id]]
    end
  end

  def show_vm_name?
    controller_name != 'hosts' && controller_name != 'compute_attributes'
  end

  def vsphere_resource_pools(form, compute_resource, disabled = false)
    resource_pools = compute_resource.available_resource_pools(:cluster_id => form.object.cluster) rescue []
    selectable_f form, :resource_pool, resource_pools, { }, :class => "col-md-2", :label => _('Resource pool'), :disabled => disabled
  end

  def vms_table
    data = if @compute_resource.supports_vms_pagination?
             { :table => 'server', :source => compute_resource_vms_path }
           else
             { :table => 'inline' }
           end

    content_tag :table, :class => table_css_classes, :width => '100%', :data => data do
      yield
    end
  end

  # Really counting vms is as expansive as loading them all, especially when
  # a filter is in place. So we create a fake count to get table pagination to work.
  def ovirt_fake_vms_count
    params['start'].to_i + 1 + [@vms.length, params['length'].to_i].min
  end

  def ovirt_vms_data
    data = @vms.map do |vm|
      [
        link_to_if_authorized(html_escape(vm.name), hash_for_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.id).merge(:auth_object => @compute_resource, :auth_action => 'view', :authorizer => authorizer)),
        vm.cores,
        number_to_human_size(vm.memory),
        "<span #{vm_power_class(vm.ready?)}>#{vm_state(vm)}</span>",
        action_buttons(vm_power_action(vm, authorizer),
                       vm_import_action(vm),
                       display_delete_if_authorized(hash_for_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.id).merge(:auth_object => @compute_resource, :authorizer => authorizer)))
      ]
    end
    JSON.fast_generate(data).html_safe
  end

  def vm_delete_action(vm, authorizer = nil)
    display_delete_if_authorized(hash_for_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity).merge(:auth_object => @compute_resource, :authorizer => authorizer), :class => 'btn btn-danger')
  end

  def new_vm?(host)
    return true unless host.present?
    return true unless host.compute_object.present?
    !host.compute_object.persisted?
  end

  def vm_import_action(vm)
    return unless Host.for_vm(@compute_resource, vm).empty?
    display_link_if_authorized(_("Import"), hash_for_import_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity))
  end
end
