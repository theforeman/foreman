class FactValue < ActiveRecord::Base
  include Authorizable
  include SearchScope::FactValue

  belongs_to_host
  belongs_to :fact_name
  delegate :name, :short_name, :compose, :to => :fact_name
  has_many :hostgroup, :through => :host

  has_one :parent_fact_name, :through => :fact_name, :source => :parent

  scope :no_timestamp_facts, lambda {
    includes(:fact_name).where("fact_names.name <> ?",:_timestamp)
  }
  scope :timestamp_facts, lambda {
    joins(:fact_name).where("fact_names.name = ?",:_timestamp)
  }
  scope :my_facts, lambda {
    unless User.current.admin? and Organization.current.nil? and Location.current.nil?
      host_ids = Host.authorized(:view_hosts, Host).select('hosts.id').all
      where(:fact_values => {:host_id => host_ids})
    end
  }

  scope :distinct, lambda { select('DISTINCT fact_values.value') }
  scope :required_fields, lambda { includes(:host, :fact_name) }
  scope :facts_counter, lambda {|value, name_id| where(:value => value, :fact_name_id => name_id) }
  scope :with_fact_parent_id, lambda {|find_ids| joins(:fact_name).merge FactName.with_parent_id(find_ids) }
  scope :with_roots, lambda { includes(:fact_name) }
  scope :root_only, lambda { with_roots.where(:fact_names => {:ancestry => nil}) }

  validates :fact_name_id, :uniqueness => { :scope => :host_id }

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
  def self.count_each(fact, options = {})
    output = []
    where({:fact_names => {:name => fact}}).joins(:fact_name).group(:value).count.each do |k,v|
      label = case options[:unit]
                when String
                  _(options[:unit]) % k
                when Array
                  n_args = options[:unit].push(k.to_i)
                  n_(*n_args) % k
                else
                  k
              end
      output << {:label => label, :data =>v }  unless v == 0
    end
    output
  end

  def self.build_facts_hash(facts)
    hash = {}
    facts.each do |fact|
      hash[fact.host.to_s] ||= {}
      hash[fact.host.to_s].update({fact.name.to_s => fact.value})
    end
    hash
  end

  # converts all strings with units (such as 1 MB) to GB scale and Sum them
  # returns an array with total sum and number of elements
  def self.to_gb(fact)
    values = select(:value).joins(:fact_name).where(:fact_names => {:name => fact}).map do |fv|
      fv.value.to_gb
    end
    [ values.sum, values.size ]
  end

end
