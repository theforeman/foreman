desc <<-END_DESC
Refreshes LDAP usergroups. It adds to an LDAP usergroup all the foreman users that belong to it, and removes foreman users
in that usergroup that do not belong in LDAP anymore.
END_DESC

namespace :ldap do
  task :refresh_usergroups => :environment do
    ExternalUsergroup.all.each do |eu|
      begin
        eu.refresh
      rescue => error
        puts "User group #{eu} could not be refreshed - LDAP source #{eu.auth_source} not available: #{error}"
      end
    end
  end
end

