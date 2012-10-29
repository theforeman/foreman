class FactValue < Puppet::Rails::FactValue
  belongs_to :host #ensures we uses our Host model and not Puppets
  delegate :name, :to => :fact_name
  has_many :hostgroup, :through => :host

  scoped_search :on => :value, :in_key=> :fact_name, :on_key=> :name, :rename => :facts, :complete_value => true
  scoped_search :on => :value, :default_order => true
  scoped_search :in => :fact_name, :on => :name, :complete_value => true, :alias => "fact"
  scoped_search :in => :host, :on => :name, :rename => :host, :complete_value => true
  scoped_search :in => :hostgroup, :on => :name, :rename => :"host.hostgroup", :complete_value => true

  scope :no_timestamp_facts, :include => [:fact_name],
              :conditions => ["fact_names.name <> ?",:_timestamp]

  scope :timestamp_facts, :joins => [:fact_name],
              :conditions => ["fact_names.name = ?",:_timestamp]

  scope :my_facts, lambda {
    return { :conditions => "" } if User.current.admin? # Admin can see all hosts

    {:conditions => sanitize_sql_for_conditions(
      [" (fact_values.host_id in (?))",Host.my_hosts.pluck(:id)])}
  }

  scope :distinct, { :select => 'DISTINCT "fact_values.value"' }
  scope :required_fields, includes(:host, :fact_name)
  scope :facts_counter, lambda {|value, name_id| where(:value => value, :fact_name_id => name_id) }

  # Todo: find a way to filter which values are logged,
  # this generates too much useless data
  #
  # audited

  # returns the average of all facts
  # required only on facts that return a unit (e.g. MB, GB etc)
  # normal  facts could be used via the sum and AR average
  def self.mem_average(fact)
    total, count = to_gb(fact)
    return 0 if count == 0
    (total / count).round(1)
  end

  # returns the rounded total of memory fact values (e.g. MB, GB etc)
  def self.mem_sum(fact)
    to_gb(fact).first.to_f.round(1)
  rescue
    0
  end

  # returns the sum of each value, e.g. how many machines with 2,4...n cpu's
  def self.count_each(fact)
    hash = {}
    all(:select => "value", :joins => :fact_name, :conditions => {:fact_names => {:name => fact}}).each do |fv|
      value = fv.value
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
