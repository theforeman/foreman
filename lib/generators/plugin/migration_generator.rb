require 'rails/generators'

module Plugin
  class MigrationGenerator < Rails::Generators::Base
    class_option :plugin_name, :required => true
    class_option :plugin_source

    attr_accessor :migration_pattern

    hook_for :orm, :required => true do |instance, klass|
      new_migration = instance.invoke klass, nil, nil, destination_root: instance.send(:plugin_source)
      # the task return a suggested new migration name. If the migration already
      # exists, the file with older timestamp would remain. In this case we
      # should search for the older file with the same name part.
      instance.migration_pattern = instance.send(:extract_migration_name, new_migration.first)
    end

    def initialize(*args)
      super
      self.destination_root = plugin_source
    end

    def copy_latest_migration
      destination_file = File.join(
        destination_root,
        'db/migrate',
        destination_file_name
      )

      unless options['pretend']
        if migration_file
          # There is no rename task for some reason...
          copy_file migration_file, destination_file
          remove_file File.join('db/migrate', migration_file)
        else
          say_status(
            :error,
            _('Could not find %{migration_name} migration in %{destination}') % {
              :migration_name => migration_pattern,
              :destination => destination_root,
            },
            :red
          )
        end
      end
      [destination_file]
    end

    private

    def extract_migration_name(migration_file_name)
      File.basename(migration_file_name).sub(/^\d*_/, '').sub(/\.rb$/, '')
    end

    # used by copy_file task to indicate where the sources are
    def source_paths
      [File.join(plugin_source, 'db/migrate')]
    end

    def destination_file_name
      File.basename(migration_file, File.extname(migration_file)) +
        ".#{plugin_name}" +
        File.extname(migration_file)
    end

    def migration_file
      @migration_file ||= begin
        full_name = Dir.glob(File.join(plugin_source, 'db/migrate/*.rb')).grep(/\d+_#{migration_pattern}.rb$/).first
        File.basename(full_name) if full_name
      end
    end

    def plugin_source
      # assuming a default folder layout for developer setup.
      @plugin_source ||= options[:plugin_source] || File.join(destination_root, "../#{plugin_name}/")
    end

    def plugin_name
      @plugin_name ||= options[:plugin_name].underscore
    end
  end
end
