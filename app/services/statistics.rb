module Statistics
  def self.charts(org_id, loc_id)
    charts = [
      CountHosts.new(:count_by => :operatingsystem, :title => "OS Distribution", :search => "os_title=~VAL~", :organization_id => org_id, :location_id => loc_id),
      CountHosts.new(:count_by => :architecture, :title => _("Architecture Distribution"), :search => "facts.architecture=~VAL~", :organization_id => org_id, :location_id => loc_id),
      CountHosts.new(:count_by => :environment, :title => _("Environment Distribution"), :search => "environment=~VAL~", :organization_id => org_id, :location_id => loc_id),
      CountHosts.new(:count_by => :hostgroup, :title => _("Host Group Distribution"), :search => "hostgroup_title=~VAL~", :organization_id => org_id, :location_id => loc_id),
      CountHosts.new(:count_by => :compute_resource, :title => _("Compute Resource Distribution"), :search => "compute_resource=~VAL~", :organization_id => org_id, :location_id => loc_id),
      CountFacts.new(:count_by => :processorcount, :unit => Nn_('%s core', '%s cores'), :title => _("Number of CPUs"), :search => "facts.processorcount=~VAL1~", :organization_id => org_id, :location_id => loc_id),
      CountFacts.new(:count_by => :manufacturer, :title => _("Hardware"), :search => "facts.manufacturer~~VAL~", :organization_id => org_id, :location_id => loc_id),
      CountNumericalFactPair.new(:count_by => :memory, :title => _("Average Memory Usage"), :organization_id => org_id, :location_id => loc_id),
      CountNumericalFactPair.new(:count_by => :swap, :title => _("Average Swap Usage"), :organization_id => org_id, :location_id => loc_id),
      CountPuppetClasses.new(:id => :puppetclass, :title => _("Class Distribution"), :search => "class=~VAL1~", :organization_id => org_id, :location_id => loc_id)
    ]

    if SETTINGS[:locations_enabled]
      charts << CountHosts.new(:count_by => :location, :title => _("Location Distribution"), :search => "location=~VAL~", :organization_id => org_id, :location_id => loc_id)
    end

    if SETTINGS[:organizations_enabled]
      charts << CountHosts.new(:count_by => :organization, :title => _("Organization Distribution"), :search => "organization=~VAL~", :organization_id => org_id, :location_id => loc_id)
    end

    charts
  end
end
