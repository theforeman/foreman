# Statistics
Statistic.without_auditing do
  Statistic.where(:name => 'Architecture Distribution', :value => 'architecture').first_or_create
  Statistic.where(:name => 'Number of CPUs', :value => 'processorcount').first_or_create
  Statistic.where(:name => 'Hardware', :value => 'manufacturer').first_or_create
end
