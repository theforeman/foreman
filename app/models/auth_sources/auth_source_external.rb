class AuthSourceExternal < AuthSource

  def authenticate(login, password)
    raise NotImplementedError, "#{__class__} does not support authenticate"
  end

  def auth_method_name
    "EXTERNAL"
  end
  alias_method :to_label, :auth_method_name
end
