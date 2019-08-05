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

          def snapshot_path(template)
            path = File.join(fetch_metadata(template.template, :model, 'undefined'),
                             fetch_metadata(template.template, :kind, 'undefined'),
                             template.name)

            root = @overrides.try(:[], path) || SNAPSHOTS_DIRECTORY
            File.join(root, "#{path}.snap.txt")
          end

          def register_override(template, override)
            @overrides ||= {}
            @overrides[template] = override
          end

          private

          def fetch_metadata(content, key, default = nil)
            content_by_lines(content).find { |l| l.starts_with?("#{key}: ") }.try(:remove, "#{key}: ").try(:strip) || default
          end

          def content_by_lines(content)
            content.split("\n")
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
