object @config_report

extends "api/v2/config_reports/main"

child :logs do
  child :source do
    attribute :value => :source
  end
  child :message do
    attribute :value => :message
  end
  attribute :level
end

node :summary do |config_report|
  config_report.summary_status
end
