require 'csv'

module CsvExporter
  def self.export(resources, columns)
    Enumerator.new do |csv|
      csv << csv_header(columns)

      resources.uncached do
        resources.reorder(nil).limit(nil).find_each do |obj|
          csv << CSV.generate_line(columns.map{|c| obj.send(c)})
        end
      end
    end
  end

  def self.csv_header(columns)
    CSV.generate_line(columns.map{|c| c.to_s.titleize})
  end
end
