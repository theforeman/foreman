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

    # don't advertise any plugins to prevent different results
    module PluginSnapshotStub
      def find(id)
        nil
      end
    end
    ::Foreman::Plugin.singleton_class.send :prepend, PluginSnapshotStub

    # clean the snapshot directory in order to delete renamed ones and keep it clean
    FileUtils.rm_rf(Dir.glob(File.join(
      ::Foreman::Renderer::Source::Snapshot::SNAPSHOTS_DIRECTORY, '*')))

    DatabaseCleaner.cleaning do
      ENV['FIXTURES'] = 'settings'
      Rake::Task['db:fixtures:load'].invoke
      Setting[:unattended_url] = "http://foreman.some.host.fqdn"
      Setting[:foreman_url] = "http://foreman.some.host.fqdn"

      User.current = FactoryBot.build(:user, :admin)
      admin = FactoryBot.create(:user, :admin, password: 'password123', auth_source: FactoryBot.create(:auth_source_ldap))

      User.as(admin.login) do
        Foreman::TemplateSnapshotService.templates.each do |template|
          Foreman::Renderer::Source::Snapshot.hosts(template).each do |host|
            snapshot_path = Foreman::Renderer::Source::Snapshot.snapshot_path(template, host)
            dir = File.dirname(snapshot_path)
            FileUtils.mkdir_p(dir) unless File.directory?(dir)

            snapshot = Foreman::TemplateSnapshotService.render_template(template, host)
            File.write(snapshot_path, snapshot)
          end
        end
      end
    end
  end
end
