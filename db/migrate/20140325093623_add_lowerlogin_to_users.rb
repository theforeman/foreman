class AddLowerloginToUsers < ActiveRecord::Migration
  def up
    add_column :users, :lower_login, :string
    add_index  :users, :lower_login, :unique => true

    User.reset_column_information

    User.unscoped.order("last_login_on DESC").each do |user|
      if User.find_by_login(user.login.downcase)
        dupe = 1
        dupe += 1 while User.find_by_login(new_login="#{user.login}#{dupe}")
        say "Renaming duplicate user #{user.login} to #{new_login}"
        user.login = new_login
      else
        user.lower_login = user.login.downcase
      end

      user.save(:validate => false)
    end
  end

  def down
    remove_index  :users, :lower_login
    remove_column :users, :lower_login
  end
end
