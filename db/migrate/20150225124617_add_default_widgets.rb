class AddDefaultWidgets < ActiveRecord::Migration[4.2]
  def up
    User.all.each do |user|
      Dashboard::Manager.reset_user_to_default(user)
    end
  end

  def down
  end
end
