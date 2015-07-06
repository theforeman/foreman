object @report

attributes :id, :reported_at, :status, :metrics

child :logs do
  child :source => :sources do
    attribute :value => :source
  end
  child :message => :messages do
    attribute :value => :message
  end
  attribute :level
end

node :summary do |report|
  report.summary_status
end
