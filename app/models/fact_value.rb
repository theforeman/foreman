class FactValue < Puppet::Rails::FactValue
  belongs_to :host #ensures we uses our Host model and not Puppets
end
