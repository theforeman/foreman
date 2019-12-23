namespace :taxonomy do
  desc <<-END_DESC
    This task will update organization & location records with ignore_types.
  END_DESC
  task :update_taxonomy => :environment do
    if User.unscoped.find_by_login(User::ANONYMOUS_ADMIN).present?
      User.as_anonymous_admin do
        Organization.unscoped.each do |org|
          success = org.save
          puts "Failed to save Organization #{org.id}- #{org.errors.full_messages.inspect}" unless success
        end

        Location.unscoped.each do |loc|
          success = loc.save
          puts "Failed to save Location #{loc.id}- #{loc.errors.full_messages.inspect}" unless success
        end
      end
    end
  end
end
