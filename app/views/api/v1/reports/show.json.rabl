object @report

attributes :id, :reported_at, :status, :metrics

child :logs do
  child :source do
    attribute :value => :source
  end
  child :message do
    attribute :value => :message
  end
end

node :summary do |report|
	report.summaryStatus
end