namespace :host_reports do

  def set_keywords(conf_report)
    keywords_set = {}
    #if conf_report[:status][:applied] then set[] = true end
    if conf_report[:status][:failed] then keywords_set["PuppetFailed"] = true end
    if conf_report[:status][:failed_restarts] then keywords_set["PuppetFailedToRestart"] = true end
    #if conf_report[:status][:pending] then keywords_set[] = true end
    if conf_report[:status][:restarted] then keywords_set["PuppetRestarted"] = true end
    if conf_report[:status][:skipped] then keywords_set["PuppetSkipped"] = true end
    keywords_set.keys.to_a rescue []
  end

  def summary(conf_report, change, nochange, failure)
    {
      "foreman" => {
        "change" => change,
        "nochange" => nochange,
        "failure" => failure,
      },
      "native" => conf_report[:metrics][:resources]
    }
  end

  def make_body(conf_report, change, nochange, failure)
    body = Hash.new
    body[:migrated] = "true"
    body[:host] = conf_report[:host]
    body[:reported_at] = conf_report[:reported_at]
    body[:logs] = conf_report[:logs]
    body[:keywords] = set_keywords(conf_report)
    body[:summary] = summary(conf_report, change, nochange, failure)

    body.to_json
  end

  task :migrate, [:hosts] => :environment do

    ConfigReport.all.each do |i|
      require 'pry'
      binding.pry  
      conf_report = i[:config_report]
      reported_at = conf_report[:reported_at]

      change = conf_report.dig(:metrics, :changes, :total) || 0
      failure = conf_report.dig(:metrics, :events, :failure) || 0
      total = conf_report.dig(:metrics, :events, :total) || 0
      nochange = total - change
      body = make_body(conf_report, change, nochange, failure)

      HostReport.create(host_id: id, reported_at: reported_at, body: body, format: "puppet",
         change: change, nochange: nochange, failure: failure)
    end
  end
end