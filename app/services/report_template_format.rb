class ReportTemplateFormat
  def self.all
    @all_formats ||= [
      new(id: :csv, mime_type: 'text/csv', human_name: 'CSV'),
      new(id: :txt, mime_type: 'text/plain', human_name: 'Plain text'),
      new(id: :json, mime_type: 'application/json', human_name: 'JSON'),
      new(id: :yaml, mime_type: 'text/yaml', human_name: 'YAML'),
      new(id: :html, mime_type: 'text/html', human_name: 'HTML'),
    ]
  end

  def self.selectable
    all.reject { |f| f.id == :txt }
  end

  def self.find(id)
    all.find { |f| f.id.to_s == id.to_s }
  end

  # if the template does not support formats at all,
  # most likely custom template
  # we fallback to universal plaintext format
  def self.system
    find(:txt)
  end

  # if the template supports format selection,
  # csv is the default
  def self.default
    find(:csv)
  end

  attr_reader :id, :mime_type, :human_name

  def initialize(id:, mime_type:, human_name:)
    @id = id
    @mime_type = mime_type
    @human_name = human_name
  end

  def extension
    suggested = Mime::Type.lookup(@mime_type).symbol.to_s
    (suggested == 'text') ? 'txt' : suggested
  end
end
