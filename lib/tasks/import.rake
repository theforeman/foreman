namespace :host_reports do
  def config_report_help(id, host_id, reported_at, status, metrics, type, origin)
    config_report = Hash["id": id, "host_id": host_id, "reported_at": reported_at,
      "metrics": metrics, "type": type, "origin": origin]
    ConfigReport.create(config_report)
  end

  def set_keywords(status)
    # Values for PuppetFailed, PuppetFailedToRestart, PuppetEnvironment
    keywords_set = {}
    if status[:applied] then set[] = true end
    if status[:failed] then keywords_set["PuppetFailed"] = true end
    if status[:failed_restarts] then keywords_set["PuppetFailedToRestart"] = true end
    if status[:corrective_change] then keywords_set["PuppetCorrectiveChange"] = true end
    if status[:skipped] then keywords_set["PuppetSkipped"] = true end
    if status[:restarted] then keywords_set["PuppetRestarted"] = true end
    if status[:scheduled] then keywords_set["PuppetScheduled"] = true end
    if status[:out_of_sync] then keywords_set["PuppetOutOfSync"] = true end
    if status[:environment] then keywords_set["PuppetEnvironment"] = true end
    keywords_set.keys.to_a rescue []
  end
  
  def summary(resources, change, nochange, failure)
    {
      "foreman" => {
        "change" => change,
        "nochange" => nochange,
        "failure" => failure,
      },
      "native" => resources,
    }
  end
  
  def create_body(metrics, reported_at, status, logs, host, change, nochange, failure)
    body = Hash.new
    body[:migrated] = "true"
    body[:host] = host
    body[:reported_at] = reported_at
    body[:logs] = logs
    body[:keywords] = set_keywords(status)
    body[:summary] = summary(metrics["resources"], change, nochange, failure)

    body.to_json
  end

  def metrics_values(metrics)
    change = metrics.dig("changes", "total") || 0
    failure = metrics.dig("events", "failure") || 0
    total = metrics.dig("events", "total") || 0
    nochange = total - change || 0
    [change, failure, nochange]
  end

  def host_report_help(id, host_id, reported_at, status, metrics, origin, logs, host)
    change, failure, nochange = metrics_values(metrics)
    body = create_body(metrics, reported_at, status, logs, host, change, nochange, failure)
    host_report = Hash["id": id, "host_id": host_id, "proxy_id": nil, "reported_at": reported_at,
      "body": body, "format": origin, "change": change, "nochange": nochange, "failure": failure]
    HostReport.create(host_report)
  end

  task :import => :environment do
    CSV.foreach("reports.csv") do |csv|
      unless csv[5] == "ConfigReport" then next end
      id, host_id, reported_at, status, metrics, type, origin, logs, host = csv
      unless Host.where(:id => host_id) then next end
      status = JSON.parse(status)
      metrics = JSON.parse(metrics) # YAML?? -> change metrics_values
      if origin == "Ansible"
        origin = "ansible"
      elsif origin == "Puppet"
        origin = "puppet"
      end
      host_report_help(id, host_id, reported_at, status, metrics, origin, logs, host)
      config_report_help(id, host_id, reported_at, status, metrics, type, origin)
    end
  end
end
