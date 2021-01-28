class UpdateLoginDelegationDescription < ActiveRecord::Migration[6.0]
  def up
    Setting.where(name: 'authorize_login_delegation').update_all(description: "Authorize login delegation with REMOTE_USER HTTP header")
    Setting.where(name: 'authorize_login_delegation_api').update_all(description: "Authorize login delegation with REMOTE_USER HTTP header for API calls too")
  end

  def down
    Setting.where(name: 'authorize_login_delegation').update_all(description: "Authorize login delegation with REMOTE_USER environment variable")
    Setting.where(name: 'authorize_login_delegation_api').update_all(description: "Authorize login delegation with REMOTE_USER environment variable for API calls too")
  end
end
