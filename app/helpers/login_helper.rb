module LoginHelper
  def login_props
    {
      token: form_authenticity_token,
      caption: Setting.replace_keywords(Setting[:login_text]),
      alerts: flash_inline,
      logoSrc: image_path("login_logo.png"),
      oidcProviders: oidc_providers_for_login,
    }
  end

  def mount_login
    render('common/login', props: login_props)
  end

  def oidc_providers_for_login
    AuthSourceOidc.all.map do |provider|
      {
        id: provider.id,
        name: provider.name,
        loginUrl: "/users/auth/#{provider.provider_name}",
      }
    end
  end
end
