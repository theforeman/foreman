module LoginHelper
  def login_props
    {
      token: form_authenticity_token,
      caption: Setting.replace_keywords(Setting[:login_text]),
      alerts: flash_inline,
      logoSrc: image_path("login_logo.png"),
      oidcProviders: AuthSourceOidc.enabled.order(:name).map do |auth_source|
        { name: auth_source.name, url: start_oidc_authentication_path(:id => auth_source) }
      end,
    }
  end

  def mount_login
    render('common/login', props: login_props)
  end
end
