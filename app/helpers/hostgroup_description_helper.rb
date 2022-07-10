module HostgroupDescriptionHelper
  UI.register_hostgroup_description do
    hostgroup_actions_provider :base_hostgroup_actions
  end

  def base_hostgroup_actions(hostgroup)
    [
      { action: display_link_if_authorized(_('Nest'), hash_for_nest_hostgroup_path(id: hostgroup)), priority: 10 },
      { action: display_link_if_authorized(_('Create Host'), hash_for_new_host_path(hostgroup_id: hostgroup.id)), priority: 20 },
      { action: display_link_if_authorized(_('Clone'), hash_for_clone_hostgroup_path(id: hostgroup)), priority: 30 },
      { action: display_delete_if_authorized(hash_for_hostgroup_path(id: hostgroup).merge(auth_object: hostgroup, authorizer: authorizer), data: { confirm: warning_message(hostgroup) }), priority: 40 },
    ]
  end
end
