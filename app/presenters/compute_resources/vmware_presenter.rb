module ComputeResources
  class VmwarePresenter < ::ComputeResourcePresenter
    def vms_list_columns
      [
        { name: 'name', label: _('Name') },
        { name: 'folder', label: _('Folder'), value: :path },
        { name: 'cpus', label: _('CPUs') },
        { name: 'memory', label: _('Memory') },
        { name: 'operatingsystem', label: _('Operating system') },
        # { name: 'hypervisor', label: _('Hypervisor'), value: ->(vm, _presenter){ vm.hypervisor&.name } },
      ]
    end

    def vm_actions(vm, authorizer: nil, host: nil, for_view: :list)
      return super if for_view == :show
      [
        vm_power_action(vm, authorizer),
        (view.display_link_if_authorized(_('Console'), view.hash_for_console_compute_resource_vm_path(:compute_resource_id => compute_resource, :id => vm.identity).merge(:auth_object => compute_resource, :authorizer => authorizer)) if vm.ready?),
        vm_import_action(vm),
        view.display_delete_if_authorized(view.hash_for_compute_resource_vm_path(:compute_resource_id => compute_resource, :id => vm.identity).merge(:auth_object => compute_resource, :authorizer => authorizer)),
      ]
    end
  end
end
