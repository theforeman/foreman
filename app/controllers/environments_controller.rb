class EnvironmentsController < ApplicationController
  active_scaffold :environment do |config|
    config.columns = %w{name}
    config.nested.add_link("Hosts", [:hosts])
    config.nested.add_link("Classes", [:puppetclasses])

    config.action_links.add 'import_classes_and_environments', :label => 'Import environments and classes', :inline => false,
        :page => :true , :type => :table
  end
end
