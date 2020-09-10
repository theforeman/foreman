module LoginHelper
  def login_props
    {
      token: form_authenticity_token,
      version: SETTINGS[:version].version,
      caption: Setting[:login_text],
      alerts: flash_inline,
      logoSrc: image_path("login_logo.png"),
    }
  end

  def mount_login
    render('common/login', props: login_props)
  end
end
