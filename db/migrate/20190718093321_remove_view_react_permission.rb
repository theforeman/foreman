class RemoveViewReactPermission < ActiveRecord::Migration[5.2]
  def change
    Permission.where(name: 'view_react').destroy_all
  end
end
