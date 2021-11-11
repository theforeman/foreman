class NilifyEmptyProxyCredentials < ActiveRecord::Migration[6.0]
  def up
    HttpProxy.unscoped.where(username: "").update_all(username: nil)
    HttpProxy.unscoped.where(password: "").update_all(password: nil)
  end

  def down
    HttpProxy.unscoped.where(username: nil).update_all(username: "")
    HttpProxy.unscoped.where(password: nil).update_all(password: "")
  end
end
