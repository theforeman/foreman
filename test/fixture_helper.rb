class FixtureHelper
  FIXTURE_PATH = "#{Rails.root}/tmp/combined_fixtures/"

  def self.combine(source_directories)
    FileUtils.rm_rf(FIXTURE_PATH) if File.directory?(FIXTURE_PATH)
    Dir.mkdir(FIXTURE_PATH)

    source_directories.each do |directory|
      Find.find(directory).each do |source_path|
        next unless source_path.ends_with?('.yaml') || source_path.ends_with?('.yml')
        partial_path = source_path.sub(directory, '')
        destination_path = File.join(FIXTURE_PATH, partial_path)

        FileUtils.mkdir_p(File.dirname(destination_path))
        File.open(destination_path, 'a') {|f| f.write(File.read(source_path)) }
      end
    end
  end
end
