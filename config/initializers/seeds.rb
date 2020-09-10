return unless (ForemanInternal.table_exists? rescue(false)) && !Foreman.in_rake? && !Rails.env.test?

if ActiveRecord::Base.connection.migration_context.needs_migration?
  Rails.logger.warn("Migrations pending, skipping seeding. Please run `foreman-rake db:migrate` manually.")
  return
end

Foreman::Application.configure do |app|
  config.after_initialize do
    seeder = ForemanSeeder.new

    if seeder.hash_changed?
      seeder.execute
    else
      Rails.logger.info("No new seed file updates found. Skipping")
    end
  rescue StandardError => e
    Rails.logger.error("Error while attempting to seed database, please run `foreman-rake db:seed` manually!")
    Rails.logger.error(e.full_message)
  end
end
