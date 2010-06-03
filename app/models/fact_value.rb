class FactValue < Puppet::Rails::FactValue
  belongs_to :host #ensures we uses our Host model and not Puppets
  delegate :name, :to => :fact_name

  # Todo: find a way to filter which values are logged,
  # this generates too much useless data
  #
  # acts_as_audited

  # returns the average of all facts
  # required only on facts that return a unit (e.g. MB, GB etc)
  # normal  facts could be used via the sum and AR average
  def self.mem_average(fact)
    values=all(:select => "value", :joins => :fact_name, :conditions => {:fact_names => {:name => fact}})
    return values.size > 0 ? (values.map{|fv| fv.value.to_gb}.sum / values.size).round_with_precision(1) : 0
  end

  # returns the sum of each value, e.g. how many machines with 2,4...n cpu's
  def self.count_each(fact)
    hash = {}
    all(:select => "value", :joins => :fact_name, :conditions => {:fact_names => {:name => fact}}).each do |fv|
      value = fv.value.strip.humanize
      if hash[value].nil?
        hash[value] = 1
      else
        hash[value] += 1
      end
    end
    hash
  end

end
