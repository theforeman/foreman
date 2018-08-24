class SnapshotSource
  SNAPSHOTS_DIRECTORY = Rails.root.join('test', 'unit', 'foreman', 'renderer', 'snapshots')

  def initialize(filepath)
    @filename = File.basename(filepath, '.*')
    @content = File.read(filepath)
  end

  attr_reader :content, :template

  def name
    @name ||= fetch_metadata(:name, filename)
  end

  def snapshot_path
    @snapshot_path ||= File.join(SNAPSHOTS_DIRECTORY, fetch_metadata(:model, 'undefined'),
      fetch_metadata(:kind, 'undefined'), "#{name}.snap.txt")
  end

  def find_snippet(name)
    snippet_path = Rails.root.join('app', 'views', 'unattended', 'provisioning_templates', 'snippet', "_#{name}.erb")
    return unless File.file?(snippet_path)
    content = File.read(snippet_path)
    Template.new(name: name, template: content, snippet: true)
  end

  private

  attr_reader :filename

  def fetch_metadata(key, default = nil)
    content_by_lines.find { |l| l.starts_with?("#{key}: ") }.try(:remove, "#{key}: ").try(:strip) || default
  end

  def content_by_lines
    @content_by_lines = content.split("\n")
  end
end
