require "resolv"
# This models a DNS domain and so represents a site.
class Domain < ActiveRecord::Base
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Taxonomix
  include StripLeadingAndTrailingDot
  include Parameterizable::ByIdName
  include ScopedSearchExtensions

  audited :allow_mass_assignment => true, :except => [:hosts_count, :hostgroups_count]

  validates_lengths_from_database
  has_many :hostgroups
  #order matters! see https://github.com/rails/rails/issues/670
  before_destroy EnsureNotUsedBy.new(:interfaces, :hostgroups, :subnets)
  has_many :subnet_domains, :dependent => :destroy
  has_many :subnets, :through => :subnet_domains
  belongs_to :dns, :class_name => "SmartProxy"
  has_many :domain_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :domain
  has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "DomainParameter"
  has_many :interfaces, :class_name => 'Nic::Base'
  has_many :primary_interfaces, :class_name => 'Nic::Base', :conditions => { :primary => true }
  has_many :hosts, :through => :interfaces
  has_many :primary_hosts, :through => :primary_interfaces, :source => :host

  accepts_nested_attributes_for :domain_parameters, :allow_destroy => true

  before_validation :punycode_name
  include ParameterValidators
  validates :name, :presence => true, :uniqueness => true, :domain_name => true
  validates :fullname, :uniqueness => true, :allow_blank => true, :allow_nil => true

  scoped_search :on => :name, :complete_value => true, :ext_method => :search_by_unicode_name, :default_order => true
  scoped_search :on => :fullname, :complete_value => true
  scoped_search :on => :hosts_count
  scoped_search :on => :hostgroups_count
  scoped_search :in => :domain_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :only_explicit => true, :rename => :params

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("domains.name")
    end
  }

  def self.complete_for_domain_name(query, output, title)
    if query.include? title
      output.map!{|item| item.gsub(/(xn\-\-\S*)/){|match| SimpleIDN.to_unicode(match)} }
    end
  end

  def self.complete_for(query, opts = {})
    query.gsub!(/name\s+=\s+(\p{Word}+)/u){ "name = #{SimpleIDN.to_ascii($1)}" }
    output = super(query, opts)
    Domain.complete_for_domain_name(query, output, 'name')
    output
  end

  def self.search_by_unicode_name(key, operator, value)
    value = value_to_sql(operator, SimpleIDN.to_ascii(value))
    conditions = sanitize_sql_for_conditions(["name #{operator} ?", value])
    domains = Domain.where(conditions).pluck(:id)
    opts  = domains.empty? ? "< 0" : "IN (#{domains.join(',')})"
    {:conditions => "domains.id #{opts}"}
  end

  class Jail < Safemode::Jail
    allow :name, :fullname
  end

  # return the primary name server for our domain based on DNS lookup
  # it first searches for SOA record, if it failed it will search for NS records
  def nameservers
    return [] if Setting.query_local_nameservers
    dns = Resolv::DNS.new
    ns = dns.getresources(name, Resolv::DNS::Resource::IN::SOA).collect {|r| r.mname.to_s}
    ns = dns.getresources(name, Resolv::DNS::Resource::IN::NS).collect {|r| r.name.to_s} if ns.empty?
    ns.to_a.flatten
  end

  def resolver
    ns = nameservers
    Resolv::DNS.new ns.empty? ? nil : {:search => name, :nameserver => ns, :ndots => 1}
  end

  def proxy
    ProxyAPI::DNS.new(:url => dns.url) if dns and !dns.url.blank?
  end

  def lookup(query)
    Net::DNS.lookup query, proxy, resolver
  end

  def dot_strip_attrs
    ['name']
  end

  # overwrite method in taxonomix, since domain is not direct association of host anymore
  def used_taxonomy_ids(type)
    return [] if new_record?
    Host::Base.joins(:primary_interface).where(:nics => {:domain_id => id}).uniq.pluck(type).compact
  end

  def punycode_name
    self.name = SimpleIDN.to_ascii(name.downcase)
  end

  def unicode_name
    SimpleIDN.to_unicode(name)
  end

  def to_s
    unicode_name
  end

  def to_label
    unicode_name
  end
end
