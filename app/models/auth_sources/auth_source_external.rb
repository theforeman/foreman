class AuthSourceExternal < AuthSource
  include Taxonomix

  def authenticate(login, password)
  end

  def auth_method_name
    "EXTERNAL"
  end
  alias_method :to_label, :auth_method_name

  # assumes every user is valid
  # as we do not do any authentication ourselves
  def valid_user?(name)
    name.present?
  end

  def supports_refresh?
    false
  end
end
