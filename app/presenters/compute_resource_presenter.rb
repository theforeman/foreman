class ComputeResourcePresenter
  def self.for_cr(compute_resource, view)
    klass = "#{compute_resource.provider.camelcase}Presenter".safe_constantize
    Rails.logger.warn("Do not know how to present #{compute_resource.provider}") unless klass
    klass ||= self
    klass.new(compute_resource, view)
  end

  attr_accessor :model, :view
  alias_method :compute_resource, :model

  def initialize(compute_resource, view)
    @model, @view = compute_resource, view
  end

  # TODO: preparation of the cache should be private in the future
  def prepare_host_cache!(vms)
    @hosts = Host.for_vm(compute_resource, vms).group_by(:uuid)
  end

  def prepare_host_existance_cache!(vms)
    @existing_hosts = Host.for_vm(compute_resource, vms).pluck(:uuid)
  end

  # ----- Actions -------
  def vm_actions(vm, authorizer: nil, host: nil, for_view: :list)
    actions = vm_power_actions(vm, authorizer: authorizer, host: host, for_view: for_view)
    actions << vm_delete_action(vm, authorizer)
    actions << vm_console_action(vm)
    if (host = host_for(vm))
      actions << view_host_action(host)
    else
      actions.concat(vm_import_actions(vm, :class => 'btn btn-default')) unless has_host?(vm)
      actions << vm_associate_action(vm)
    end
    actions
  end

  def vm_power_actions(vm, authorizer: nil, host: nil, for_view: :list)
    [vm_power_action(vm, authorizer)]
  end

  def vm_import_actions(vm, html_options = {})
    actions = []
    actions << view.display_link_if_authorized(
      _("Import as managed Host"),
      view.hash_for_import_compute_resource_vm_path(
        :compute_resource_id => compute_resource,
        :id => vm.identity,
        :type => 'managed'),
      html_options
    )
    actions << view.display_link_if_authorized(
      _("Import as unmanaged Host"),
      view.hash_for_import_compute_resource_vm_path(
        :compute_resource_id => compute_resource,
        :id => vm.identity,
        :type => 'unmanaged'),
      html_options
    )
    actions
  end

  def vm_import_action(vm, html_options = {})
    vm_import_actions(vm, html_options).join.html_safe
  end

  def view_host_action(host)
    view.display_link_if_authorized(_("Host"), view.hash_for_host_path(:id => host), :class => 'btn btn-default')
  end

  DELEGATED_ACTIONS = [
    :vm_power_action,
    :vm_pause_action,
    :vm_delete_action,
    :vm_console_action,
    :vm_associate_action
  ]
  delegate *DELEGATED_ACTIONS, to: :view

  private

  def has_host?(vm)
    return @existing_hosts.include?(vm.identity.to_s) if @existing_hosts
    return @hosts.has_key?(vm.identity.to_s) if @hosts
    !Host.for_vm(compute_resource, vm).empty?
  end

  def host_for(vm)
    return @hosts[vm.identity.to_s] if @hosts
    Host.for_vm(compute_resource, vm).first
  end
end
