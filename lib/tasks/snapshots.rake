desc 'Snapshots tasks'
namespace :snapshots do
  desc "Generate snapshots"
  task :generate => :environment do
    unless Rails.env.test?
      puts "This task can only be run in test environment"
      exit
    end

    require 'database_cleaner'
    require 'factory_bot_rails'

    DatabaseCleaner.cleaning do
      ENV['FIXTURES'] = 'settings'
      Rake::Task['db:fixtures:load'].invoke

      User.current = FactoryBot.build(:user, :admin)
      admin = FactoryBot.create(:user, :admin, password: 'password123', auth_source: FactoryBot.create(:auth_source_ldap))

      User.as(admin.login) do
        Foreman::TemplateSnapshotService.templates.each do |template|
          snapshot_path = Foreman::Renderer::Source::Snapshot.snapshot_path(template)
          dir = File.dirname(snapshot_path)
          FileUtils.mkdir_p(dir) unless File.directory?(dir)

          snapshot = Foreman::TemplateSnapshotService.render_template(template)

          File.open(snapshot_path, 'w') { |f| f.write(snapshot) }
        end
      end
    end
  end
end
