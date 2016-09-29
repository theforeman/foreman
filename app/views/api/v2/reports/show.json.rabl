object @report

extends "api/v2/reports/main"

child :logs do
  child :source do
    attribute :value => :source
  end
  child :message do
    attribute :value => :message
  end
  attribute :level
end

node :summary do |report|
  report.summary_status
end
