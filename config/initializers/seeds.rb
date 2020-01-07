return unless (ForemanInternal.table_exists? rescue(false)) && !Foreman.in_rake? && !Rails.env.test?

Foreman::Application.configure do |app|
  config.after_initialize do
    seeder = ForemanSeeder.new

    if seeder.hash_changed?
      seeder.execute
    else
      Rails.logger.info("No new seed file updates found. Skipping")
    end
  end
end
