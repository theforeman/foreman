# Simple advisory lock manager for PostgreSQL. When used on different database
# it does not perform any locking. Rails (6) only implements advisory non-blocking
# locking for migrations via Connection#get_advisory_lock which is not suitable
# for application use. More information:
#
# https://www.postgresql.org/docs/current/explicit-locking.html
# https://www.kostolansky.sk/posts/postgresql-advisory-locks/
#
module Foreman
  class AdvisoryLockManager
    class << self
      # Performs transaction-level advisory lock which is automaticaly released when the
      # built-in explicit transaction ends, or when the session ends.
      def with_transaction_lock(lock_name)
        if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
          lock_id = generate_lock_id(lock_name)
          ActiveRecord::Base.transaction do
            Rails.logger.debug("Acquiring Advisory-Transaction-Lock '#{lock_name}' -> #{lock_id}")
            sql = ActiveRecord::Base.sanitize_sql("SELECT pg_advisory_xact_lock(#{lock_id})")
            ActiveRecord::Base.connection.execute(sql)
            yield
          end
        else
          yield
        end
      end

      # Performs session-level advisory lock which is automaticaly released when the block
      # returns. Does not create explicit transaction.
      def with_session_lock(lock_name)
        if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
          begin
            lock_id = generate_lock_id(lock_name)
            Rails.logger.debug("Acquiring Advisory-Session-Lock '#{lock_name}' -> #{lock_id}")

            sql = ActiveRecord::Base.sanitize_sql("SELECT pg_advisory_lock(#{lock_id})")
            ActiveRecord::Base.connection.execute(sql)
            yield
          ensure
            sql = ActiveRecord::Base.sanitize_sql("SELECT pg_advisory_unlock(#{lock_id})")
            ActiveRecord::Base.connection.execute(sql)
          end
        else
          yield
        end
      end

      private

      # PostgreSQL requires signed 64 bit (BIGINT).
      def generate_lock_id(lock_name)
        Digest::SHA512.digest(lock_name).unpack1('q')
      end
    end
  end
end
