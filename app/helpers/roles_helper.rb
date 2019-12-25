module RolesHelper
  def role_link(role)
    if role.builtin? || role.locked?
      content_tag(:em, h(role.name))
    else
      content_tag(:span) do
        link_to_if_authorized(h(role.name), hash_for_edit_role_path(:id => role))
      end
    end
  end

  def display_link_unless_locked(name, path_hash, role)
    display_link_if_authorized name, path_hash unless role.locked?
  end

  def link_to_unless_locked(name, role, options = {}, html_options = {})
    if role&.locked?
      link_to_function name, nil, html_options.merge!(:class => "#{html_options[:class]} disabled", :disabled => true)
    else
      link_to_if_authorized name, options, html_options
    end
  end

  def new_link_unless_locked(name, path_hash, role)
    new_link name, path_hash if role && !role.locked?
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
