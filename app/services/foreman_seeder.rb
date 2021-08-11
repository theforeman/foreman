require 'digest'

class ForemanSeeder
  FOREMAN_INTERNAL_KEY = 'database_seed'.freeze
  ADVISORY_LOCK = 'database_seed'.freeze

  attr_reader :seeds

  class << self
    attr_accessor :is_seeding
  end

  def initialize
    @seeds = order_seeds(foreman_seeds) + order_seeds(plugin_seeds)
    @hashed_files = @seeds + templates
  end

  def foreman_seeds
    Dir.glob(Rails.root + 'db/seeds.d/*.rb')
  end

  def plugin_seeds
    Foreman::Plugin.registered_plugins.collect do |name, plugin|
      Dir.glob(plugin.engine.root + 'db/seeds.d/*.rb') if plugin.engine
    end.flatten.compact
  end

  def templates
    SeedHelper.report_templates + SeedHelper.provisioning_templates + SeedHelper.partition_tables_templates
  end

  def hash
    hashes = @hashed_files.collect { |seed| Digest::SHA256.file(seed).base64digest }
    Digest::SHA256.base64digest(hashes.join)
  end

  def execute
    Foreman::AdvisoryLockManager.with_transaction_lock(ADVISORY_LOCK) do
      # if we had to wait for the lock it is likely that the seeding has already been done, no need to seed again
      unless hash_changed?
        Rails.logger.info("Seeding skipped because the hash was unchanged")
        return
      end

      self.class.is_seeding = true
      begin
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
      ensure
        self.class.is_seeding = false
      end
      save_hash

      Rails.logger.info("All seed files executed") unless Rails.env.test?
    end
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

  def order_seeds(seeds)
    seeds.sort_by do |seed_path|
      seed_path.split("/").last.match(/^\d*/)[0].to_i
    end
  end
end
