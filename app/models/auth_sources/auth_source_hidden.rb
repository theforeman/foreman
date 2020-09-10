class AuthSourceHidden < AuthSource
  def authenticate(login, password)
  end

  def auth_method_name
    "HIDDEN"
  end
  alias_method :to_label, :auth_method_name

  # assumes every user is valid
  # as we do not allow any authentication
  def valid_user?(name)
    name.present?
  end

  def can_set_password?
    false
  end
end
