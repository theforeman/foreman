module Statistics
  def self.charts
    [
      CountHosts.new(:count_by => :operatingsystem, :title => ("OS Distribution"), :search =>"os_title=~VAL~"),
      CountHosts.new(:count_by => :architecture, :title => _("Architecture Distribution"), :search => "facts.architecture=~VAL~"),
      CountHosts.new(:count_by => :environment, :title => _("Environment Distribution"), :search => "environment=~VAL~"),
      CountFacts.new(:count_by => :processorcount, :unit => Nn_('%s core', '%s cores'), :title => _("Number of CPUs"), :search => "facts.processorcount=~VAL1~"),
      CountFacts.new(:count_by => :manufacturer, :title => _("Hardware"), :search => "facts.manufacturer~~VAL~"),
      CountNumericalFactPair.new(:count_by => :memory, :title => _("Average memory usage")),
      CountNumericalFactPair.new(:count_by => :swap, :title => _("Average swap usage")),
      CountPuppetClasses.new(:id => :puppetclass, :title => _("Class Distribution"), :search => "class=~VAL1~")
    ]
  end
end
