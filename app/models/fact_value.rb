class FactValue < Puppet::Rails::FactValue
  belongs_to :host #ensures we uses our Host model and not Puppets
  delegate :name, :to => :fact_name

  scoped_search :on => :value, :in_key=> :fact_name, :on_key=> :name, :rename => :facts, :complete_value => true
  scoped_search :on => :value, :default_order => true
  scoped_search :in => :fact_name, :on => :name, :complete_value => true, :alias => "fact"
  scoped_search :in => :host, :on => :name, :rename => :host, :complete_value => true

  named_scope :no_timestamp_facts, :include => [:fact_name],
              :conditions => ["fact_names.name <> ?",:_timestamp]

  named_scope :timestamp_facts, :joins => [:fact_name],
              :conditions => ["fact_names.name = ?",:_timestamp]

  named_scope :distinct, { :select => 'DISTINCT "fact_values.value"' }
  named_scope :required_fields, { :include => :host }
  default_scope :order => 'LOWER(fact_values.value)'

  # Todo: find a way to filter which values are logged,
  # this generates too much useless data
  #
  # acts_as_audited

  # returns the average of all facts
  # required only on facts that return a unit (e.g. MB, GB etc)
  # normal  facts could be used via the sum and AR average
  def self.mem_average(fact)
    total, count = to_gb(fact)
    return 0 if count == 0
    (total / count).round_with_precision(1)
  end

  # returns the rounded total of memory fact values (e.g. MB, GB etc)
  def self.mem_sum(fact)
    to_gb(fact).first.round_with_precision(1)
  rescue
    0
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

  def self.build_facts_hash facts
    hash = {}
    facts.each do |fact|
      hash[fact.host.to_s] ||= {}
      hash[fact.host.to_s].update({fact.name.to_s => fact.value})
    end
    return hash
  end

  private
  # converts all strings with units (such as 1 MB) to GB scale and Sum them
  # returns an array with total sum and number of elements
  def self.to_gb fact
    values = all(:select => "value", :joins => :fact_name, :conditions => {:fact_names => {:name => fact}}).map do |fv|
      fv.value.to_gb
    end
    [ values.sum, values.size ]
  end

end
