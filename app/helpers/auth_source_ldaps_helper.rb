module AuthSourceLdapsHelper
  def on_the_fly?(authsource)
    return false if authsource.new_record?
    authsource.onthefly_register?
  end

  def account_help_data
    @account_help_data ||= {
      'active_directory' => _("Example value is <code>%s</code>") % 'DOMAIN\Foreman',
      'free_ipa' => _("Example value is <code>%s</code>") % 'uid=foreman,cn=users,cn=accounts,dc=example,dc=com',
      'posix' => _("Example value is <code>%s</code>") % 'uid=foreman,dc=example,dc=com',
    }
  end

  def base_dn_help_data
    @base_dn_help_data ||= {
      'active_directory' => _("Example value is <code>%s</code>") % 'CN=Users,DC=example,DC=COM',
      'free_ipa' => _("Example value is <code>%s</code>") % 'cn=users,cn=accounts,dc=example,dc=com',
      'posix' => _("Example value is <code>%s</code>") % 'dc=example,dc=com',
    }
  end

  def groups_base_dn_help_data
    @groups_base_dn_help_data ||= {
      'active_directory' => _("Example value is <code>%s</code>") % 'CN=Users,DC=example,DC=com',
      'free_ipa' => _("Example value is <code>cn=groups,cn=accounts,dc=example,dc=com</code> or <code>cn=ng,cn=compat,dc=example,dc=com</code> if you use netgroups"),
      'posix' => _("Example value is <code>%s</code>") % 'dc=example,dc=com',
    }
  end
end
