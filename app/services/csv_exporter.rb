require 'csv'

module CsvExporter
  def self.export(resources, columns, header = nil)
    header ||= default_header(columns)
    raise ArgumentError, "Columns and header row aren't the same length" unless columns.length == header.length
    # need to save the current context as the enumerator is executed by a separate thread
    context = Foreman::ThreadSession::Context.get
    Enumerator.new do |csv|
      Foreman::ThreadSession::Context.set(context)
      csv << CSV.generate_line(header)
      columns.map!{|c| c.to_s.split('.').map(&:to_sym)}
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
