require 'digest'

class ForemanSeeder
  FOREMAN_INTERNAL_KEY = 'database_seed'.freeze

  attr_reader :seeds

  def initialize
    @seeds = (foreman_seeds + plugin_seeds).sort_by { |seed| seed.split("/").last }
  end

  def foreman_seeds
    Dir.glob(Rails.root + 'db/seeds.d/*.rb')
  end

  def plugin_seeds
    Foreman::Plugin.registered_plugins.collect do |name, plugin|
      engine = (name.to_s.tr('-', '_').camelize + '::Engine').constantize
      Dir.glob(engine.root + 'db/seeds.d/*.rb')
    rescue NameError => e
      Foreman::Logging.exception("Failed to register plugin #{name}", e)
      nil
    end.flatten.compact
  end

  def hash
    hashes = @seeds.collect { |seed| Digest::SHA256.file(seed).base64digest }
    Digest::SHA256.base64digest(hashes.join)
  end

  def execute
    @seeds.each do |seed|
      Rails.logger.info("Seeding #{seed}") unless Rails.env.test?

      admin = User.unscoped.find_by_login(User::ANONYMOUS_ADMIN)
      # anonymous admin does not exist until some of seed step creates it, therefore we use it only when it exists
      if admin.present?
        User.as_anonymous_admin do
          load seed
        end
      else
        load seed
      end
    end

    save_hash

    Rails.logger.info("All seed files executed") unless Rails.env.test?
  end

  def save_hash
    ForemanInternal.find_or_create_by(key: FOREMAN_INTERNAL_KEY).update_attribute(:value, hash)
  end

  def old_hash
    ForemanInternal.find_or_create_by(key: FOREMAN_INTERNAL_KEY).value
  end

  def hash_changed?
    old_hash != hash
  end
end
