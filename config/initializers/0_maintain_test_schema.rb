ActiveRecord::Migration.maintain_test_schema! if Rails.env.test? && !Foreman.in_rake?('db:test:prepare')
