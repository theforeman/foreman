module ComputeResourcesHelper
  include LookupKeysHelper

  def vm_state(vm)
    if vm.state == 'PAUSED'
      ' ' + _("Paused")
    else
      vm.ready? ? _("On") : _("Off")
    end
  end

  def action_string(vm)
    vm.ready? ? ' ' + _("Off") : ' ' + _("On")
  end

  def vm_power_class(s)
    "class='label #{s ? 'label-success' : 'label-default'}'".html_safe
  end

  def vm_power_action(vm, authorizer = nil)
    opts = hash_for_power_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity).merge(:auth_object => @compute_resource, :permission => 'power_compute_resources_vms', :authorizer => authorizer)
    html = vm.ready? ? { :data => { :confirm =>_("Are you sure you want to power %{act} %{vm}?") % { :act => action_string(vm).downcase.strip, :vm => vm }}, :class => "btn btn-danger" } :
                       { :class => "btn btn-info" }

    display_link_if_authorized "Power #{action_string(vm)}", opts, html.merge(:method => :put)
  end

  def vm_pause_action(vm, authorizer = nil)
    opts = hash_for_pause_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity).merge(:auth_object => @compute_resource, :permission => 'power_compute_resources_vms', :authorizer => authorizer)
    pause_action = vm.ready? ? _('Pause') : _('Resume')
    html = vm.state.downcase == 'paused' ? { :class => "btn btn-info" } :
                                           { :data => { :confirm =>_("Are you sure you want to %{act} %{vm}?") % { :act => pause_action.downcase, :vm => vm } }, :class => "btn btn-danger" }

    display_link_if_authorized pause_action, opts, html.merge(:method => :put)
  end

  def password_placeholder(obj, attr = nil)
    pass = obj.read_attribute(attr).present? || obj.read_attribute(:password_hash).present?
    pass ? "********" : ''
  end

  def list_datacenters(compute)
    return [] unless compute.uuid || controller.action_name == 'test_connection'
    compute.datacenters
  rescue Foreman::FingerprintException => e
    compute.errors[:pubkey_hash] = e
    []
  rescue => e
    Foreman::Logging.exception("Failed listing datacenters", e)
    []
  end

  def list_providers
    providers = ComputeResource.providers.map do |provider_name, provider_class|
      [provider_class.constantize.provider_friendly_name, provider_name]
    end
    providers.sort_by { |provider| provider.first }
  end

  def unset_password?
    action_name == "edit" || action_name == "test_connection"
  end
end
