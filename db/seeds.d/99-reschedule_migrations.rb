# Reschedule migrations which were skipped

def reschedule_migration(id)
  sql = "DELETE FROM schema_migrations WHERE version = '#{id}'"
  ActiveRecord::Base.connection.execute sql
end

reschedule_migration('20141110084848') if Puppetclass.count > 0
