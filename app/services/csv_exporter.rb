require 'csv'

module CsvExporter
  class ExportDefinition
    attr_reader :label

    def initialize(key, label: nil, callback: nil)
      @key = key.to_s.split('.').map(&:to_sym)
      @label = label || derive_label(key)
      @callback = callback
    end

    def derive_label(key)
      key.to_s.titleize.gsub('.', ' - ')
    end

    def evaluate(object)
      if @callback
        @callback.call(object)
      else
        @key.inject(object, :try)
      end
    end
  end

  class << self
    def export(resources, columns, header = nil)
      columns = preprocess_columns(columns)
      header ||= default_header(columns)
      raise ArgumentError, "Columns and header row aren't the same length" unless columns.length == header.length
      # need to save the current context as the enumerator is executed by a separate thread
      context = Foreman::ThreadSession::Context.get

      Enumerator.new do |csv|
        Foreman::ThreadSession::Context.set(**context)
        csv << CSV.generate_line(header)
        resources.uncached do
          resources.reorder(nil).limit(nil).find_each do |obj|
            csv << CSV.generate_line(columns.map { |c| c.evaluate(obj) }.flatten)
          end
        end
      end
    end

    def preprocess_columns(columns)
      columns.map do |column|
        if column.is_a? ExportDefinition
          column
        else
          ExportDefinition.new(column)
        end
      end
    end

    def default_header(columns)
      columns.map(&:label)
    end
  end
end
