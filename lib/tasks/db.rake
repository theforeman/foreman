# TRANSLATORS: do not translate
desc <<-END_DESC
  Reset PostgreSQL sequences to their max values. Does nothing on other databases.

  Examples:
    rake db:sequence:reset - reset primary key sequence to max value (only for PostgreSQL)

END_DESC

namespace :db do
  namespace :sequence do
    task :reset => :environment do
      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with?('postgresql')
        ActiveRecord::Base.connection.tables.each do |t|
          ActiveRecord::Base.connection.reset_pk_sequence!(t)
        end
      end
    end
  end
end
