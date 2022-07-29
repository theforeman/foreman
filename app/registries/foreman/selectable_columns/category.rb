module Foreman
  module SelectableColumns
    class Category < Array
      attr_reader :id, :label

      def initialize(id, label, table, default: false)
        @id = id
        @label = label
        @table = table
        @default = default
        @columns_to_use = HashWithIndifferentAccess.new
        super(0)
      end

      def column(key, th:, td:)
        self << { key: key.to_s, th: th, td: td }.with_indifferent_access
      end

      def use_column(key, from:)
        return if from.to_s == @id

        @columns_to_use[from] ||= []
        @columns_to_use[from] << key.to_s
      end

      # This instance can be updated after it was created by DSL, but
      #   only at the initialization time.
      # This method is only for actual runtime usage,
      #   after the Storage is fully defined/updated.
      # Thus, saving once computed result.
      def keys
        @keys ||= columns.map { |c| c[:key] }.sort
      end

      def default?
        @default
      end

      def columns
        self + foreign_columns
      end

      private

      # This is meant for actual runtime usage,
      #  after the categories are fully defined.
      # Thus, saving once computed result.
      def foreign_columns
        @foreign_columns ||= @columns_to_use.keys.map do |category_id|
          @table.find { |cat| cat.id == category_id }&.select { |col| @columns_to_use[category_id].include?(col[:key]) }
        end.flatten.compact
      end
    end
  end
end
