module RolesHelper
  def role_link(role)
    if role.builtin?
      content_tag(:em, h(role.name))
    else
      content_tag(:span) do
        link_to_if_authorized(h(role.name), hash_for_edit_role_path(:id => role))
      end
    end
  end

  def delete_role_confirmation(role)
    if role.users.any?
      role_users_count = role.users.size
      n_("Warning! This will remove %{name} from %{number} user. are you sure?",
         "Warning! This will remove %{name} from %{number} users. are you sure?", role_users_count) % {name: role.name, number: role_users_count}
    else
      _("Delete %s?") % role.name
    end
  end
end
