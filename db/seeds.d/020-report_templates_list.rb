class ReportTemplatesList
  class << self
    def seeded_templates
      [
        { :name => 'Host statuses CSV', :source => 'host_statuses_csv.erb' }
      ]
    end
  end
end
