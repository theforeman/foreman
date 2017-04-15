if Rails.env.test? && !Foreman.in_rake?('db:migrate') && !Foreman.in_rake?('db:test:prepare') && !defined?(Spring)
  ActiveRecord::Migration.maintain_test_schema!
end
