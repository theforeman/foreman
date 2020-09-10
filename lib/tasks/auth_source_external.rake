namespace :auth_source_external do
  desc 'Creates an external authentication source named "External", if no external authentication source exists.'
  task :create => :environment do
    User.as_anonymous_admin do
      if AuthSourceExternal.any?
        puts "Failed to create external authentication source. External authentication source named '#{AuthSourceExternal.pluck(:name)}' with id '#{AuthSourceExternal.pluck(:id)}' is already present."
      else
        AuthSourceExternal.create!(name: 'External')
        puts 'Successfully created external authentication source.'
      end
    end
  end
end
