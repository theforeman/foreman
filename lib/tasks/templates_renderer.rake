# TRANSLATORS: do not translate
desc <<~END_DESC
  Render templates from a directory

  Available conditions:
    * DIRECTORY        => Path to the folder where the templates are stored

    Example:
      rake templates:render DIRECTORY=/tmp/community-templates/provisioning_templates

END_DESC

namespace :templates do
  task render: :environment do
    source_directory = ENV['DIRECTORY'].to_s

    abort(Rainbow('Must provide a valid path to a directory.').red) unless File.directory?(source_directory)

    User.as_anonymous_admin do
      service = Foreman::RenderTemplatesFromFolder.new(source_directory: source_directory)
      service.render_all
      if service.errors.any?
        puts Rainbow('Errors occured while rendering the templates.').red
        puts ''
        service.errors.each do |template, message|
          puts " ==== #{template.name} ===="
          puts Rainbow("(#{template.template_path})").blue
          puts " -> #{message}"
          puts ''
        end
        abort(Rainbow("Failed to render the templates.").red)
      end

      puts Rainbow('Successfully rendered all templates.').green
    end
  end
end
