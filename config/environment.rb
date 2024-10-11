# Load the rails application
require File.expand_path('application', __dir__)

# https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING
ENV['DATABASE_URL'] ||= case Rails.env
                       when 'production'
                         'postgresql://'
                       else
                         "postgresql:///foreman-#{Rails.env}"
                       end

# Initialize the rails application
Foreman::Application.initialize!
