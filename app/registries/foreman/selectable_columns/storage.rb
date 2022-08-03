module Foreman
  module SelectableColumns
    class Storage
      include Singleton

      class << self
        def tables
          @tables ||= ActiveSupport::HashWithIndifferentAccess.new
        end

        def define(name, &block)
          return Foreman::Logging.logger('app').warn _('Table %s is already defined, ignoring.') % name if tables[name]

          table = SelectableColumns::Table.new(name)
          table.instance_eval(&block)
          tables[name] = table
        end

        def register(name, &block)
          return Foreman::Logging.logger('app').warn _('Table %s is not defined, ignoring.') % name unless tables[name]

          tables[name].instance_eval(&block)
        end

        # This is for UI data mostly
        def defined_for(table)
          return Foreman::Logging.logger('app').warn _('Table %s is not defined, ignoring.') % table unless tables[table]

          tables[table].map do |category|
            {
              id: category.id,
              name: category.label,
              columns: category.columns.map { |c| { id: c[:key], name: c[:th][:label] } },
            }
          end
        end

        def selected_by(user, table)
          return unless tables[table]

          selected_keys = user.table_preferences.find_by(name: table)&.columns&.sort
          result = if selected_keys
                     tables[table].select { |category| (category.keys & selected_keys).any? }
                                  .map(&:columns)
                                  .flatten
                                  .select { |col| selected_keys.include?(col[:key]) }
                   else
                     tables[table].select { |category| category.default? }
                                  .map(&:columns)
                                  .flatten
                   end
          result.uniq
        end
      end
    end
  end
end
