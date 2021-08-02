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
    html = power_action_html(vm)

    display_link_if_authorized "Power #{action_string(vm)}", opts, html.merge(:method => :put)
  end

  def power_action_html(vm)
    if vm.ready?
      {
        :data => { :confirm => _("Are you sure you want to power %{act} %{vm}?") % { :act => action_string(vm).downcase.strip, :vm => vm }},
        :class => "btn btn-danger",
      }
    else
      { :class => "btn btn-info" }
    end
  end

  def vm_pause_action(vm, authorizer = nil)
    opts = hash_for_pause_compute_resource_vm_path(:compute_resource_id => @compute_resource, :id => vm.identity).merge(:auth_object => @compute_resource, :permission => 'power_compute_resources_vms', :authorizer => authorizer)
    html = pause_action_html(vm)

    display_link_if_authorized pause_action_string(vm), opts, html.merge(:method => :put)
  end

  def pause_action_html(vm)
    pause_action = pause_action_string(vm).downcase
    if vm.state.downcase == 'paused'
      { :class => "btn btn-info" }
    else
      {
        :data => { :confirm => _("Are you sure you want to %{act} %{vm}?") % { :act => pause_action, :vm => vm } },
        :class => "btn btn-danger",
      }
    end
  end

  def pause_action_string(vm)
    vm.ready? ? _('Pause') : _('Resume')
  end

  def password_placeholder(obj, attr = nil)
    pass = obj.read_attribute(attr).present? || obj.read_attribute(:password_hash).present?
    pass ? "********" : ''
  end

  def list_datacenters(compute)
    return [] unless compute.uuid || controller.action_name == 'test_connection'
    compute.datacenters
  rescue Foreman::FingerprintException => e
    compute.errors.add(:pubkey_hash, e.message)
    []
  rescue Foreman::UsernameOrPasswordException => e
    Foreman::Logging.exception("Failed listing datacenters", e)
    compute.errors.add(:datacenter, e.message)
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
    action_name == "edit" || (action_name == "test_connection" && params[:cr_id].present?)
  end

  def test_connection_button_f(f, success, caption = nil)
    caption ||= _("Test Connection")
    btn_class = success ? 'btn-success' : 'btn-default'
    spinner_class = success ? 'spinner-inverse' : nil
    spinner_button_f(f, caption, "tfm.computeResource.testConnection(this)",
      :id => 'test_connection_button',
      :spinner_id => 'test_connection_indicator',
      :class => btn_class,
      :spinner_class => spinner_class,
      :'data-url' => test_connection_compute_resources_path)
  end

  def load_button_f(f, success, failure_caption)
    caption = success ? _("Test Connection") : failure_caption
    test_connection_button_f(f, success, caption)
  end

  def load_datacenters_button_f(f, success)
    load_button_f(f, success, _("Load Datacenters"))
  end

  def http_proxy_field(f)
    select_f(f, :http_proxy_id, HttpProxy.all, :id, :name,
      {:include_blank => true },
      { :label => _("HTTP Proxy") }
    )
  end
end
