require 'csv'

module CsvExporter
  def self.export(resources, columns)
    header = csv_header(columns)
    Enumerator.new do |csv|
      csv << header
      columns.map!{|c| c.to_s.split('.').map(&:to_sym)}

      resources.uncached do
        resources.reorder(nil).limit(nil).find_each do |obj|
          csv << CSV.generate_line(columns.map{|c| c.inject(obj, :try)})
        end
      end
    end
  end

  def self.csv_header(columns)
    CSV.generate_line(columns.map{|c| c.to_s.titleize})
  end
end
