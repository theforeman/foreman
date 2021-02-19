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
            ActiveRecord::Base.connection.execute("SELECT pg_advisory_xact_lock(#{lock_id})")
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
            ActiveRecord::Base.connection.execute("SELECT pg_advisory_lock(#{lock_id})")
            yield
          ensure
            ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(#{lock_id})")
          end
        else
          yield
        end
      end

      private

      # PostgreSQL requires signed 64 bit (BIGINT), this uses built-in Ruby hash to generate it.
      # The method can result in different results with different Ruby versions, but this is
      # unlikely to happen (possibly during rolling restart when upgrading to new Ruby).
      def generate_lock_id(lock_name)
        lock_name.to_s.hash & 0x7FFFFFFFFFFFFFFF
      end
    end
  end
end
