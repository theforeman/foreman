module SSO
  class Apache < Base
    delegate :session, :to => :controller

    CAS_USERNAME = 'REMOTE_USER'
    ENV_TO_ATTR_MAPPING = {
      'REMOTE_USER_EMAIL'     => :mail,
      'REMOTE_USER_FIRSTNAME' => :firstname,
      'REMOTE_USER_LASTNAME'  => :lastname,
    }

    def available?
      return false unless Setting['authorize_login_delegation']
      return false if controller.api_request? && !(Setting['authorize_login_delegation_api'])
      return false if http_token.present?
      return false if controller.api_request? && request.env[CAS_USERNAME].blank?
      true
    end

    def support_expiration?
      true
    end

    def support_fallback?
      true
    end

    # If REMOTE_USER is provided by the web server then
    # authenticate the user without using password.
    def authenticated?
      return false unless (self.user = request.env[CAS_USERNAME])
      attrs = { :login => user }.merge(additional_attributes)
      group_count = request.env['REMOTE_USER_GROUP_N'].to_i
      if group_count > 0
        attrs[:groups] = []
        group_count.times { |i| attrs[:groups] << request.env["REMOTE_USER_GROUP_#{i + 1}"] }
      end

      return false unless User.find_or_create_external_user(attrs, Setting['authorize_login_delegation_auth_source_user_autocreate'])
      store
      true
    end

    def support_login?
      request.fullpath != login_url
    end

    def authenticate!
      self.has_rendered = true
      controller.redirect_to controller.main_app.extlogin_users_path
    end

    def login_url
      controller.main_app.extlogin_users_path
    end

    def logout_url
      return Setting['login_delegation_logout_url'] if Setting['login_delegation_logout_url'].present?
      controller.extlogout_users_path
    end

    def expiration_url
      controller.main_app.extlogin_users_path
    end

    private

    def additional_attributes
      attrs = {}
      ENV_TO_ATTR_MAPPING.each do |header, attribute|
        if request.env.has_key?(header)
          attrs[attribute] = convert_encoding(request.env[header].dup)
        end
      end
      attrs
    end

    def convert_encoding(value)
      if value.respond_to?(:force_encoding)
        value.force_encoding(Encoding::UTF_8)
        unless value.valid_encoding?
          value.encode(Encoding::UTF_8, Encoding::ISO_8859_1, { :invalid => :replace, :replace => '-' }).force_encoding(Encoding::UTF_8)
        end
      else
        Iconv.new('UTF-8//IGNORE', 'UTF-8').iconv(value) rescue value
      end
      value
    end

    def store
      session[:sso_method] = self.class.to_s
    end
  end
end
