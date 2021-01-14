class NilifyEmptyProxyCredentials < ActiveRecord::Migration[6.0]
  def up
    if User.unscoped.find_by_login(User::ANONYMOUS_ADMIN).present?
      User.as_anonymous_admin do
        HttpProxy.where(username: "").update_all(username: nil)
        HttpProxy.where(password: "").update_all(password: nil)
      end
    end
  end

  def down
    if User.unscoped.find_by_login(User::ANONYMOUS_ADMIN).present?
      User.as_anonymous_admin do
        HttpProxy.where(username: nil).update_all(username: "")
        HttpProxy.where(password: nil).update_all(password: "")
      end
    end
  end
end
