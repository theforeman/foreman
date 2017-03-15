module UserUsergroupCommon
  def ssh_authorized_keys
    ssh_keys.map(&:to_export)
  end
end
