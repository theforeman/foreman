class ComputeResourcePresenter
  def self.for(compute_resource, view:)
    klass = "ComputeResources::#{compute_resource.provider.camelcase}Presenter".safe_constantize
    Rails.logger.debug("Do not know how to present #{compute_resource.provider}") unless klass
    klass ||= self
    klass.new(compute_resource, view)
  end

  class VmsTablePresenter
    attr_reader :presenter

    def initialize(presenter, vms, authorizer: nil)
      @presenter = presenter
      @vms = vms
      @authorizer = authorizer
    end

    # in case of json data load, firt hit is with nil @vms
    def vms
      @vms || []
    end

    def columns
      presenter.vms_list_columns
    end

    def render_column(column, vm)
      presenter.view.content_tag(:td) do
        render_value(column, vm)
      end
    end

    def render_value(column, vm)
      value = value(column, vm)
      case column[:name]
      when 'name'
        presenter.view.link_to_if_authorized(
          value,
          presenter.view.hash_for_compute_resource_vm_path(
            :compute_resource_id => presenter.compute_resource,
            :id => vm.identity
          ).merge(
            :auth_object => presenter.compute_resource,
            :auth_action => 'view',
            :authorizer => @authorizer
          )
        )
      else
        value
      end
    end

    def value(column, vm)
      case column[:value]
      when nil
        vm.send(column[:name])
      when Symbol
        vm.send(column[:value])
      when Proc
        column[:value].call(vm, presenter)
      end
    end

    private

    def hosts
      @hosts ||= Host.for_vm(presenter.compute_resource, @vms).group_by(:uuid)
    end
  end

  attr_accessor :model, :view
  alias_method :compute_resource, :model

  def initialize(compute_resource, view)
    @model, @view = compute_resource, view
  end

  def vms_list_columns
    [{ name: 'name', label: _('Name') }]
  end

  def vms_table(vms)
    VmsTablePresenter.new(self, vms)
  end

  # ----- Actions -------
  def vm_actions(vm, authorizer: nil, host: nil, for_view: :list)
    host = host_for(vm) if host.nil?
    actions = vm_power_actions(vm, authorizer: authorizer, host: host, for_view: for_view)
    actions << vm_delete_action(vm, authorizer)
    actions << vm_console_action(vm)
    if host
      actions << view_host_action(host)
    else
      actions.concat(vm_import_actions(vm, :class => 'btn btn-default'))
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
    :vm_associate_action,
  ]
  delegate(*DELEGATED_ACTIONS, to: :view)

  private

  def has_host?(vm)
    !Host.for_vm(compute_resource, vm).empty?
  end

  def host_for(vm)
    Host.for_vm(compute_resource, vm).first
  end
end
