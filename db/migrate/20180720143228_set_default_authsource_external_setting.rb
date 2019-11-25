class SetDefaultAuthsourceExternalSetting < ActiveRecord::Migration[5.1]
  def up
    Setting.where(:name => 'authorize_login_delegation_auth_source_user_autocreate').set('authorize_login_delegation_auth_source_user_autocreate',
      'Name of the external auth source where unknown externally authentication users (see authorize_login_delegation) should be created (If you want to prevent the autocreation, keep unset)',
      'External', 'Authorize login delegation auth source user autocreate')
  end

  def down
    Setting.where(:name => 'authorize_login_delegation_auth_source_user_autocreate').set('authorize_login_delegation_auth_source_user_autocreate',
      'Name of the external auth source where unknown externally authentication users (see authorize_login_delegation) should be created (keep unset to prevent the autocreation)',
      nil, 'Authorize login delegation auth source user autocreate')
  end
end
