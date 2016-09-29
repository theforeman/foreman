AuthSource.without_auditing do
  # Auth sources
  src = AuthSourceInternal.find_by_type "AuthSourceInternal"
  AuthSourceInternal.create :name => "Internal" unless src.present?

  src = AuthSourceHidden.find_by_type "AuthSourceHidden"
  AuthSourceHidden.create :name => "Hidden" unless src.present?
end
