module Foreman
  module SelectableColumns
    class Table < Array
      attr_reader :name

      def initialize(name)
        @name = name
        super(0)
      end

      def category(id, label: _('General'), default: false, &block)
        category = find_or_create(id.to_sym, label, default)
        category.instance_eval(&block)
      end

      private

      def find_or_create(id, label, default)
        category = find { |c| c.id == id }
        unless category
          category = Category.new(id, label, default: default)
          self << category
        end
        category
      end
    end
  end
end
