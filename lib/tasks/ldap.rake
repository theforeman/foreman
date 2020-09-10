namespace :ldap do
  task :refresh_usergroups => :environment do
    desc <<-END_DESC
    Refreshes LDAP usergroups. It adds to an LDAP usergroup all the foreman users that belong to it, and removes foreman users
    in that usergroup that do not belong in LDAP anymore.
    END_DESC
    User.as_anonymous_admin do
      ExternalUsergroup.all.each do |eu|
        eu.refresh
      rescue => error
        puts "User group #{eu} could not be refreshed - LDAP source #{eu.auth_source} not available: #{error}"
      end
    end
  end

  task :remove_deleted_users => :environment do
    desc <<-END_DESC
    Deletes all foreman users that authenticate via LDAP, but whose LDAP users do not exist anymore.
    Also deletes them as the owner of their hosts.
    END_DESC
    User.as_anonymous_admin do
      User.joins(:auth_source).where(:'auth_sources.type' => 'AuthSourceLdap').each do |user|
        unless user.auth_source.valid_user?(user.login)
          Host.where(:owner => user).update_all(:owner_type => nil, :owner_id => nil)
          user.destroy!
          puts "Deleted user #{user.login}"
        end
      end
    end
  end
end
