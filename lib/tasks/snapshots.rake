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
    require_relative '../../test/unit/foreman/renderer/template_snapshot_service'

    DatabaseCleaner.cleaning do
      ENV['FIXTURES'] = 'settings'
      Rake::Task['db:fixtures:load'].invoke

      User.current = FactoryBot.build(:user, :admin)
      admin = FactoryBot.create(:user, :admin, password: 'password123', auth_source: FactoryBot.create(:auth_source_ldap))

      User.as(admin.login) do
        host = TemplateSnapshotService.host

        TemplateSnapshotService.sources.each do |source|
          dir = File.dirname(source.snapshot_path)
          FileUtils.mkdir_p(dir) unless File.directory?(dir)

          scope = Foreman::Renderer.get_scope(host: host, source: source)
          snapshot = Foreman::Renderer.render(source, scope)

          File.open(source.snapshot_path, 'w') { |f| f.write(snapshot) }
        end
      end
    end
  end
end
