require 'csv'

module CsvExporter
  def self.export(resources, columns, header = nil)
    header ||= default_header(columns)
    raise ArgumentError, "Columns and header row aren't the same length" unless columns.length == header.length
    # need to save the current context as the enumerator is executed by a separate thread
    context = Foreman::ThreadSession::Context.get

    Enumerator.new do |csv|
      Foreman::ThreadSession::Context.set(**context)
      csv << CSV.generate_line(header)
      cols = columns.map { |c| c.to_s.split('.').map(&:to_sym) }
      resources.uncached do
        resources.reorder(nil).limit(nil).find_each do |obj|
          csv << CSV.generate_line(cols.map { |c| c.inject(obj, :try) })
        end
      end
    end
  end

  def self.default_header(columns)
    columns.map { |c| c.to_s.titleize }
  end
end
