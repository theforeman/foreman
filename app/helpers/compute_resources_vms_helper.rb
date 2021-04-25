module ComputeResourcesVmsHelper
  def vm_power_actions(host, vm)
    button_group(
      if vm
        html_opts = vm.ready? ? {:data => {:confirm => _('Are you sure?')}, :class => "btn btn-danger"} : {:class => "btn btn-success"}
        link_to_if_authorized _("Power%s") % state(vm.ready?), hash_for_power_host_path(:power_action => vm.ready? ? :stop : :start).merge(:auth_object => host, :permission => 'power_hosts'),
          html_opts.merge(:method => :put)
      else
        link_to(_("Unknown Power State"), '#', :disabled => true, :class => "btn btn-warning")
      end
    )
  end

  def vm_console(host, vm)
    options = { :class => "btn btn-info", :id => "console-button" }
    if vm&.ready?
      link_to_if_authorized(_("Console"), hash_for_console_host_path().merge(:auth_object => host, :permission => 'console_hosts'),
        options)
    else
      link_to(_("Console"), '#', options.merge(:disabled => true))
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
          value.map { |v| v.try(:name) || v.try(:to_s) || v }.to_sentence
        when Fog::Time, Time
          date_time_relative_value(value)
        when nil
          _("N/A")
        else
          (method == :memory) ? number_to_human_size(value) : value.to_s
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
      :password => console[:password],
    }
    if supports_spice_xpi?
      options.merge!(
        :address     => console[:address],
        :secure_port => console[:secure_port],
        :subject     => console[:subject],
        :title       => _("%s - Press Shift-F12 to release the cursor.") % console[:name]
      )
    end
    options[:ca_cert] = URI.escape(console[:ca_cert]) if console[:ca_cert].present?
    options
  end

  def libvirt_networks(compute_resource)
    networks   = compute_resource.networks
    select     = []
    select << [_('Physical (Bridge)'), :bridge]
    select << [_('Virtual (NAT)'), :network] if networks.any?
    select
  end

  def vsphere_networks(compute_resource, cluster_id = nil)
    networks = compute_resource.networks(cluster_id: cluster_id)
    networks.map do |net|
      net_id = net.id
      net_name = net.name
      net_name += " (#{net.virtualswitch})" if net.virtualswitch
      [net_id, net_name]
    end
  end

  def available_actions(vm, authorizer = nil)
    return default_available_actions(vm, authorizer) unless defined? Fog::OpenStack::Compute::Server
    case vm
    when Fog::OpenStack::Compute::Server
      openstack_available_actions(vm, authorizer)
    else
      default_available_actions(vm, authorizer)
    end
  end

  def common_available_actions(vm, authorizer = nil)
    actions = []
    actions << vm_delete_action(vm, authorizer)
    actions << vm_console_action(vm)
    host_action = vm_host_action(vm)
    if host_action
      actions << host_action
    else
      actions << vm_import_action(vm, :class => 'btn btn-default')
      actions << vm_associate_action(vm)
    end
    actions
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

    (actions + common_available_actions(vm, authorizer)).compact
  end

  def default_available_actions(vm, authorizer = nil)
    actions = []
    actions << vm_power_action(vm, authorizer)
    (actions + common_available_actions(vm, authorizer)).compact
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
    subnets.each { |sub| subnet_vpc_hash[sub.subnet_id] = {:vpc_id => sub.vpc_id, :subnet_name => sub.tag_set["Name"] || sub.subnet_id} }
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
    security_groups.map { |sg| [sg.name, sg.group_id] if sg.vpc_id == vpc_id }.compact
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
    if form.object.cluster
      options = {}
      resource_pools = compute_resource.available_resource_pools(:cluster_id => form.object.cluster) rescue []
    else
      disabled = true
      options = { include_blank: _('Please select a cluster') }
      resource_pools = []
    end
    selectable_f form, :resource_pool, resource_pools, options, :class => "col-md-2", :label => _('Resource pool'), :disabled => disabled
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

  def ovirt_storage_domains_for_select(compute_resource)
    compute_resource.storage_domains.map { |sd| OpenStruct.new({ id: sd.id, label: "#{sd.name} (" + _("Available") + ": #{sd.available.to_i / 1.gigabyte} GiB, " + _("Used") + ": #{sd.used.to_i / 1.gigabyte} GiB)" }) }
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
          display_delete_if_authorized(hash_for_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.id).merge(:auth_object => @compute_resource, :authorizer => authorizer))),
      ]
    end
    JSON.fast_generate(data).html_safe
  end

  def vm_delete_action(vm, authorizer = nil)
    display_delete_if_authorized(hash_for_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity).merge(:auth_object => @compute_resource, :authorizer => authorizer), :class => 'btn btn-danger')
  end

  def vsphere_scsi_controllers(compute_resource)
    scsi_controllers = {}
    compute_resource.scsi_controller_types.each { |type| scsi_controllers[type[:key]] = type[:title] }
    scsi_controllers
  end

  def new_vm?(host)
    return true unless host.present?
    compute_object = host.compute_object
    return true unless compute_object.present?
    !compute_object.persisted?
  end

  def vm_host_action(vm)
    host = Host.for_vm(@compute_resource, vm).first
    return unless host
    display_link_if_authorized(_("Host"), hash_for_host_path(:id => host), :class => 'btn btn-default')
  end

  def vm_import_action(vm, html_options = {})
    @_linked_hosts_cache ||= Host.where(:compute_resource_id => @compute_resource.id).pluck(:uuid)
    return if @_linked_hosts_cache.include?(vm.identity.to_s)

    import_managed_link = display_link_if_authorized(
      _("Import as managed Host"),
      hash_for_import_compute_resource_vm_path(
        :compute_resource_id => @compute_resource,
        :id => vm.identity,
        :type => 'managed'),
      html_options
    )
    import_unmanaged_link = display_link_if_authorized(
      _("Import as unmanaged Host"),
      hash_for_import_compute_resource_vm_path(
        :compute_resource_id => @compute_resource,
        :id => vm.identity,
        :type => 'unmanaged'),
      html_options
    )

    import_managed_link + import_unmanaged_link
  end

  def vm_associate_action(vm)
    display_link_if_authorized(
      _("Associate VM"),
      hash_for_associate_compute_resource_vm_path(
        :compute_resource_id => @compute_resource,
        :id => vm.identity
      ).merge(
        :auth_object => @compute_resource,
        :permission => 'edit_compute_resources'),
      :title => _("Associate VM to a Foreman host"),
      :method => :put,
      :class => "btn btn-default"
    )
  end

  def vm_console_action(vm)
    return unless vm.ready?
    link_to_if_authorized(
      _("Console"),
      hash_for_console_compute_resource_vm_path.merge(
        :auth_object => @compute_resource,
        :id => vm.identity
      ),
      {
        :id => "console-button",
        :class => "btn btn-info",
      }
    )
  end

  def vmware_vm_hypervisor_name(vm)
    vm.hypervisor&.name
  rescue RbVmomi::Fault => e
    if e.fault.instance_of?(RbVmomi::VIM::NoPermission)
      "<#{_('Missing permission')} #{e.fault.privilegeId}>"
    else
      raise e
    end
  end
end
