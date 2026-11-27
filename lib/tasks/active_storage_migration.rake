namespace :foreman do
  namespace :storage do
    desc 'Copy Active Storage blobs between configured services; preview unless APPLY=true'
    task :migrate => :environment do
      source = ENV.fetch('FROM_SERVICE')
      destination = ENV.fetch('TO_SERVICE')
      apply = ENV.fetch('APPLY', 'false')
      abort 'FROM_SERVICE and TO_SERVICE must not be empty' if source.empty? || destination.empty?
      abort 'APPLY must be true or false' unless ['true', 'false'].include?(apply)

      counts = Foreman::ActiveStorageMigrator.new(
        :source => source, :destination => destination, :apply => apply == 'true'
      ).run
      abort 'Some blobs could not be migrated; original objects were retained' if counts[:failed].positive?
    end
  end
end
