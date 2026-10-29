namespace :foreman do
  namespace :avatars do
    desc 'Copy legacy LDAP avatars to Active Storage; preview only unless APPLY=true'
    task :migrate => :environment do
      apply = ENV.fetch('APPLY', 'false')
      abort 'APPLY must be true or false' unless ['true', 'false'].include?(apply)

      counts = User.as_anonymous_admin do
        Foreman::LdapAvatarMigrator.new(:apply => apply == 'true').run
      end
      abort 'Some avatars could not be migrated; original files were retained' if counts[:failed].positive? || counts[:missing].positive?
    end
  end
end
