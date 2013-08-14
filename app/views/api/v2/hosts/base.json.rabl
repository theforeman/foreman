object @host

attributes :name, :id, :last_report, :ip, :mac

associated_attributes :operatingsystem => :to_label, :hostgroup => :to_label
associated_attributes :environment, :model, :location, :organization
