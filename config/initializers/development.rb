if Rails.env.development? && ! ENV['FOREMAN_LOG_SQL_ALL']
  module ActiveRecord
    class LogSubscriber
      alias :old_sql :sql

      def sql(event)
        unless event.payload[:sql] =~ /SELECT.*FROM "(settings|(taxable_)?taxonomies)"/
          old_sql(event)
        end
      end
    end
  end
end

