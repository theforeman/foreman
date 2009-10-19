class FactValue < Puppet::Rails::FactValue
  belongs_to :host #ensures we uses our Host model and not Puppets

  # Todo: find a way to filter which values are logged,
  # this generates too much useless data
  #
  # acts_as_audited

end
