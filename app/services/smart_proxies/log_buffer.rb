class SmartProxies::LogBuffer
  def initialize(hash)
    @logs = hash
  end

  def log_entries
    @logs['logs'] || []
  end

  def aggregated_logs
    @aggregated ||= begin
      aggregated = { 'debug' => 0, 'info' => 0, 'warn' => 0, 'error' => 0, 'fatal' => 0 }
      log_entries.each do |log|
        level = log['level'].try(:downcase)
        if aggregated[level]
          aggregated[level] += 1
        else
          aggregated[level] = 1
        end
      end
      aggregated
    end
  end

  def failed_modules
    @logs['info'].try(:fetch, 'failed_modules') || {}
  end

  def failed_module_names
    failed_modules.keys || []
  end

  def debug_messages
    aggregated_logs['debug'] || 0
  end

  def info_messages
    aggregated_logs['info'] || 0
  end

  def info_or_debug_messages
    (info_messages + debug_messages) || 0
  end

  def warn_messages
    aggregated_logs['warn'] || 0
  end

  def fatal_messages
    aggregated_logs['fatal'] || 0
  end

  def error_messages
    aggregated_logs['error'] || 0
  end

  def error_or_fatal_messages
    (fatal_messages + error_messages) || 0
  end
end
