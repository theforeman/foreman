class CalculateCacheForUserRole < ActiveRecord::Migration
  def up
    UserRole.all.each(&:save!)
  end

  def down
  end
end
