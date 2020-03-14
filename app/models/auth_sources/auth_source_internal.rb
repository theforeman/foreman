class AuthSourceInternal < AuthSource
  def authenticate(login, password)
    return nil if login.blank? || password.blank?

    users.unscoped.find_by_login(login).try :matching_password?, password
  end

  def auth_method_name
    "INTERNAL"
  end
  alias_method :to_label, :auth_method_name

  def valid_user?(name)
    name.present? && users.unscoped.find_by_login(name).present?
  end

  def can_set_password?
    true
  end
end
