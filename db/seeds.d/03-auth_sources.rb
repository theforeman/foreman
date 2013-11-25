AuthSource.without_auditing do
  # Auth sources
  src = AuthSourceInternal.find_by_type "AuthSourceInternal"
  src ||= AuthSourceInternal.create :name => "Internal"

  src_hidden = AuthSourceHidden.find_by_type "AuthSourceHidden"
  src_hidden ||= AuthSourceHidden.create :name => "Hidden"
end
