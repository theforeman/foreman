module Foreman
  module SelectableColumns
    class Category < Array
      attr_reader :id, :label

      def initialize(id, label, default: false)
        @id = id
        @label = label
        @default = default
        super(0)
      end

      def column(key, th:, td:)
        self << { key: key.to_s, th: th, td: td }
      end

      # This instance is not meant to be updated after it was created by DSL
      # Thus, saving once computed keys
      def keys
        @keys ||= map { |c| c[:key] }.sort
      end

      def default?
        @default
      end
    end
  end
end
