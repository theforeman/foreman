class AddDefaultWidgets < ActiveRecord::Migration
  def up
    User.all.each do |user|
      Dashboard::Manager.reset_user_to_default(user)
    end
  end

  def down
  end
end
