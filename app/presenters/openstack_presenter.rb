class OpenstackPresenter < ComputeResourcePresenter
  def vm_power_actions(vm, authorizer: nil, host: nil, for_view: :list)
    actions = []
    if vm.state == 'ACTIVE'
      actions << vm_power_action(vm, authorizer)
      actions << vm_pause_action(vm, authorizer)
    elsif vm.state == 'PAUSED'
      actions << vm_pause_action(vm, authorizer)
    else
      actions << vm_power_action(vm, authorizer)
    end
    actions
  end
end
