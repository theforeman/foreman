class AuthSourceInternal < AuthSource

  def authenticate(login, password)
    return nil if login.blank? || password.blank?

    User.first(:conditions => ["login=?", login]).try :matching_password?, password
  end

  def auth_method_name
    "INTERNAL"
  end
  alias_method :to_label, :auth_method_name

  def can_set_password?
    true
  end
end
