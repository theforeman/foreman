class AuthSourceHidden < AuthSource
  def authenticate(login, password); end

  def auth_method_name
    "HIDDEN"
  end
  alias_method :to_label, :auth_method_name

  def can_set_password?
    false
  end
end
