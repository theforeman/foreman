module Foreman
  module SelectableColumns
    class Storage
      include Singleton

      class << self
        def tables
          @tables ||= ActiveSupport::HashWithIndifferentAccess.new
        end

        def define(name, &block)
          Foreman::Logging.logger('selectable columns').info _('Table %s is already defined, ignoring.') % name if tables[name]

          table = SelectableColumns::Table.new(name)
          table.instance_eval(&block)
          tables[name] = table
        end

        def register(name, &block)
          Foreman::Logging.logger('selectable columns').info _('Table %s is not defined, ignoring.') % name unless tables[name]

          tables[name].instance_eval(&block)
        end

        def defined_for(table)
          tables[table].reduce({}) do |defined, category|
            defined.update(category.label => category.map { |c| { c[:key] => c[:th][:label] } })
          end
        end

        def selected_by(user, table)
          selected_keys = user.table_preferences.find_by(name: table)&.columns&.sort
          if selected_keys
            tables[table].select { |category| (category.keys & selected_keys).any? }
                         .flatten
                         .select { |col| selected_keys.include?(col[:key]) }
          else
            tables[table].select { |category| category.default? }.flatten
          end
        end
      end
    end
  end
end
