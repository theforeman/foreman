module SSO
  class FormIntercept < Apache
    def login_url
      controller.main_app.login_users_path
    end

    def logout_url
      nil
    end

    def expiration_url
      controller.main_app.login_users_path
    end
  end
end
