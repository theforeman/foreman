module Foreman
  module Renderer
    module Source
      class Snapshot < Database
        SNAPSHOTS_DIRECTORY = Rails.root.join('test', 'unit', 'foreman', 'renderer', 'snapshots')

        class << self
          def load_file(filepath)
            filename = File.basename(filepath, '.*')
            content = File.read(filepath)
            name = fetch_metadata(content, :name, filename)
            Template.new(name: name, template: content)
          end

          def snapshot_variants(template)
            Dir.glob "#{File.join(SNAPSHOTS_DIRECTORY, template_path(template).tr(' ', '_'))}*"
          end

          def snapshot_path(template, suffix = 'host4dhcp')
            File.join(SNAPSHOTS_DIRECTORY, "#{template_path(template).tr(' ', '_')}.#{suffix}.snap.txt")
          end

          def template_path(template)
            File.join(fetch_metadata(template.template, :model, 'undefined'),
              fetch_metadata(template.template, :kind, 'undefined'),
              template.name)
          end

          def hosts(template)
            fetch_metadata(template.template, :test_on, ['host4dhcp'])
          end

          private

          def fetch_metadata(content, key, default = nil)
            ::Template.parse_metadata(content)[key] || default
          end
        end

        def find_snippet(snippet_name)
          snippet_path = File.join(templates_directory, 'snippet', "#{snippet_name}.erb")
          return unless File.file?(snippet_path)
          snippet_content = File.read(snippet_path)
          Template.new(name: snippet_name, template: snippet_content, snippet: true)
        end

        private

        def templates_directory
          Foreman::TemplateSnapshotService::TEMPLATES_DIRECTORY
        end
      end
    end
  end
end
