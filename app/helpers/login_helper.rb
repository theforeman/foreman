module LoginHelper
  def login_props
    alert_type = flash_inline.keys[0]
    {
      token: form_authenticity_token,
      version: SETTINGS[:version].version,
      caption: Setting[:login_text],
      alertType: alert_type,
      alertMessage: flash_inline[alert_type]
    }
  end

  def mount_login
    render('common/login', props: login_props)
  end
end
