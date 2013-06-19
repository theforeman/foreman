module ComputeResourcesHelper
  include LookupKeysHelper

  def show_console_action(state, link)
    state ? link : ""
  end

  def vm_state s
    s ? ' ' + _("Off") : ' ' + _("On")
  end

  def vm_power_class s
    "class='label #{s ? "label-success" : ""}'".html_safe
  end

  def vm_power_action vm
    opts = hash_for_power_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity)
    html = vm.ready? ? { :confirm => _('Are you sure?'), :class => "btn btn-small btn-danger" } : { :class => "btn btn-small btn-info" }

    display_link_if_authorized (_("Power %s") % vm_state(vm.ready?)), opts, html.merge(:method => :put)
  end

  def memory_options max_memory
    gb = 1024*1024*1024
    opts = [0.25, 0.5, 0.75, 1, 2, 4, 8, 16]
    opts.map{|n| [number_to_human_size(n*gb), (n*gb).to_i] unless n > (max_memory / gb)}.compact
  end

  def password_placeholder(obj)
    obj.id ? "********" : ""
  end

  def list_datacenters compute
    return [] unless compute.uuid || controller.action_name == 'test_connection'
    compute.datacenters
  rescue Foreman::FingerprintException => e
    compute.errors[:pubkey_hash] = e
    []
  rescue
    []
  end
end
