module Actions
  module Foreman
    module PuppetClass
      class Import < Actions::EntryAction
        def resource_locks
          :import_puppetclasses
        end

        def run
          # #obsolete_and_new can return nil if there's no change so we have to be careful with to_sentence
          output[:errors] = ::PuppetClassImporter.new.obsolete_and_new(input[:changed]).try(:to_sentence)
        end

        def humanized_output
          return nil if input[:changed].nil?

          humanized_output = []
          humanized_output << _('Add %s') % format_env_and_classes_input(input[:changed][:new]) if input[:changed][:new].present?
          humanized_output << _('Remove %s') % format_env_and_classes_input(input[:changed][:obsolete]) if input[:changed][:obsolete].present?
          humanized_output << _('Update %s') % format_env_and_classes_input(input[:changed][:updated]) if input[:changed][:updated].present?
          humanized_output.join("\n")
        end

        def rescue_strategy
          ::Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Import Environments and Puppet classes")
        end

        # default value for cleaning up the tasks, it can be overriden by settings
        def self.cleanup_after
          '30d'
        end

        private

        def format_env_and_classes_input(selection)
          selection.map do |environment, classes|
            classes = JSON.parse(classes)
            if classes.include?('_destroy_')
              _('environment %s') % environment
            else
              n_('environment %{environment} (%{count} class)', 'environment %{environment} (%{count} classes)', classes.size) % { :environment => environment, :count => classes.size }
            end
          end.join(', ')
        end
      end
    end
  end
end
