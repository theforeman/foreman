module ExternalLogoutHelper
  def external_logout_props
    {
      version: SETTINGS[:version].version,
      caption: Setting[:login_text],
      logoSrc: image_path("login_logo.png"),
      submitLink: extlogin_users_path,
      backgroundUrl: nil,
    }
  end

  def mount_external_logout
    container_class = "external_logout"
    content_tag(:div, nil, :class => container_class) +
    mount_react_component(
      'ExternalLogout',
      ".#{container_class}",
      external_logout_props.to_json,
      flatten_data: true
    )
  end
end
