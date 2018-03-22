class CalculateCacheForUserRole < ActiveRecord::Migration[4.2]
  def up
    UserRole.all.each do |user_role|
      (user_role.role && user_role.owner) ? user_role.save! : user_role.delete
    end
  end

  def down
  end
end
