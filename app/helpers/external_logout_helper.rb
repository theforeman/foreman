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
    react_component('ExternalLogout', external_logout_props)
  end
end
