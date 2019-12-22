AuthSource.without_auditing do
  AuthSource.skip_permission_check do
    # Auth sources
    src = AuthSourceInternal.find_by type: "AuthSourceInternal"
    AuthSourceInternal.create :name => "Internal" unless src.present?

    src = AuthSourceHidden.find_by type: "AuthSourceHidden"
    AuthSourceHidden.create :name => "Hidden" unless src.present?

    external_name = Setting[:authorize_login_delegation_auth_source_user_autocreate]
    if external_name.present? && AuthSourceExternal.find_by(name: external_name).nil?
      AuthSourceExternal.create :name => external_name
    end
  end
end
