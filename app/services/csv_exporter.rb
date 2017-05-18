require 'csv'

module CsvExporter
  def self.export(resources, columns, header = default_header(columns))
    raise ArgumentError, "Columns and header row aren't the same length" unless columns.length == header.length
    Enumerator.new do |csv|
      csv << CSV.generate_line(header)

      columns.map!{|c| c.to_s.split('.').map(&:to_sym)}
      resources.uncached do
        resources.reorder(nil).limit(nil).find_each do |obj|
          csv << CSV.generate_line(columns.map{|c| c.inject(obj, :try)})
        end
      end
    end
  end

  def self.default_header(columns)
    columns.map{|c| c.to_s.titleize}
  end
end
