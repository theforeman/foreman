class FactValue < ActiveRecord::Base
  include Authorizable
  include ScopedSearchExtensions

  belongs_to_host
  belongs_to :fact_name
  delegate :name, :short_name, :compose, :origin, :to => :fact_name
  has_many :hostgroup, :through => :host

  has_one :parent_fact_name, :through => :fact_name, :source => :parent

  scoped_search :on => :value, :in_key=> :fact_name, :on_key=> :name, :rename => :facts, :complete_value => true, :only_explicit => true, :ext_method => :search_cast_facts
  scoped_search :on => :value, :default_order => true, :ext_method => :search_value_cast_facts
  scoped_search :in => :fact_name, :on => :name, :complete_value => true, :alias => "fact"
  scoped_search :in => :host,      :on => :name, :complete_value => true, :rename => :host, :ext_method => :search_by_host_or_hostgroup, :only_explicit => true
  scoped_search :in => :hostgroup, :on => :name, :complete_value => true, :rename => :"host.hostgroup", :ext_method => :search_by_host_or_hostgroup, :only_explicit => true
  scoped_search :in => :fact_name, :on => :short_name, :complete_value => true, :alias => "fact_short_name"

  scope :no_timestamp_facts, lambda {
    eager_load(:fact_name).where("fact_names.name <> ?",:_timestamp)
  }
  scope :timestamp_facts, lambda {
    eager_load(:fact_name).where("fact_names.name = ?",:_timestamp)
  }
  scope :my_facts, lambda {
    if !User.current.admin? || Organization.expand(Organization.current).present? || Location.expand(Location.current).present?
      joins_authorized(Host, :view_hosts, :where => Host.taxonomy_conditions)
    end
  }

  scope :required_fields, -> { includes(:host, :fact_name) }
  scope :facts_counter, ->(value, name_id) { where(:value => value, :fact_name_id => name_id) }
  scope :with_fact_parent_id, ->(find_ids) { joins(:fact_name).merge FactName.with_parent_id(find_ids) }
  scope :with_roots, -> { includes(:fact_name) }
  scope :root_only, -> { with_roots.where(:fact_names => {:ancestry => nil}) }

  validates :fact_name_id, :uniqueness => { :scope => :host_id }

  def self.search_by_host_or_hostgroup(key, operator, value)
    host_or_hg = key == 'host.hostgroup' ? 'hostgroup' : 'host'
    search_term = value =~ /\A\d+\Z/ ? 'id' : 'name'
    conditions = sanitize_sql_for_conditions(["#{host_or_hg.pluralize}.#{search_term} #{operator} ?", value_to_sql(operator, value)])
    { :joins => host_or_hg.to_sym, :conditions => conditions }
  end

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
      output << {:label => label, :data =>v } unless v == 0
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

  def self.search_cast_facts(key, operator, value)
    {
      :conditions => "#{sanitize_sql_for_conditions(['fact_names.name = ?', key.split('.')[1]])} AND #{cast_facts('fact_values', key, operator, value)}",
      :include    => :fact_name
    }
  end

  def self.search_value_cast_facts(key, operator, value)
    {
      :conditions => cast_facts('fact_values', key, operator, value)
    }
  end
end
