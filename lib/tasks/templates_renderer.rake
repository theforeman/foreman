# TRANSLATORS: do not translate
desc <<-END_DESC
Render templates from a directory

Available conditions:
  * DIRECTORY        => Path to the folder where the templates are stored

  Example:
    rake templates:render DIRECTORY=/tmp/community-templates/provisioning_templates

END_DESC

namespace :templates do
  task render: :environment do
    source_directory = ENV['DIRECTORY'].to_s

    abort 'Must provide a valid path to a directory.' unless File.directory?(source_directory)

    User.as_anonymous_admin do
      service = Foreman::RenderTemplatesFromFolder.new(source_directory: source_directory)
      service.render_all
      if service.errors.any?
        puts 'Errors occured while rendering the templates.'
        puts ''
        service.errors.each do |template, message|
          puts " ==== #{template.name} ===="
          puts "(#{template.template_path})"
          puts " -> #{message}"
          puts ''
        end
        abort "Failed to render the templates."
      end

      puts 'Successfully rendered all templates.'
    end
  end
end
