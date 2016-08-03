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
end
