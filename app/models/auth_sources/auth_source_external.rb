class AuthSourceExternal < AuthSource

  def authenticate(login, password)
    return nil
  end

  def auth_method_name
    "EXTERNAL"
  end
  alias_method :to_label, :auth_method_name
end
