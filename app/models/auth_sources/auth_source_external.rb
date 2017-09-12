class AuthSourceExternal < AuthSource
  scoped_search :on => :name, :complete_value => :true

  default_scope lambda {
    with_taxonomy_scope do
      order("#{AuthSourceExternal.table_name}.name")
    end
  }

  def authenticate(login, password); end

  def auth_method_name
    "EXTERNAL"
  end
  alias_method :to_label, :auth_method_name
end
