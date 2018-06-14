desc "Telemetry helper tasks"
namespace :telemetry do
  desc "List all metrics"
  task :metrics => :environment do
    telemetry = Foreman::Telemetry.instance
    puts "| Metric name | Labels | Type | Description |"
    puts "| ----------- | ------ | ---- | ----------- |"
    telemetry.metrics.sort.each do |element|
      m_name, m_desc, m_labels, m_type, = element
      puts "| #{m_name} | #{m_labels.join(',')} | #{m_type} | #{m_desc} |"
    end
  end

  desc "Generate exporter mapping for statsd_exporter"
  task :prometheus_statsd, [:output] => [:environment] do |t|
    telemetry = Foreman::Telemetry.instance
    File.open(ENV["output"] || "mapping.yaml", "w") do |f|
      mappings = []
      telemetry.metrics.sort.each do |element|
        m_name, m_desc, m_labels, m_type, m_buckets = element
        metric = {}
        labels = {}
        metric["name"] = m_name
        metric["match"] = m_name + (".*" * m_labels.count)
        m_labels.each_with_index do |label, i|
          labels[label.to_s] = "$#{i + 1}"
        end
        metric["labels"] = labels
        metric["help"] = m_desc
        metric["buckets"] = m_buckets.dup if m_buckets
        metric["timer_type"] = "histogram" if m_type == :histogram
        mappings << metric if m_labels.count > 0
      end
      result = {"mappings" => mappings}
      f.puts result.to_yaml
    end
  end
end
