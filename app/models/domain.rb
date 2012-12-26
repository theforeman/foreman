require "resolv"
# This models a DNS domain and so represents a site.
class Domain < ActiveRecord::Base
  include Authorization
  include Taxonomix

  has_many :hosts
  has_many :hostgroups
  #order matters! see https://github.com/rails/rails/issues/670
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, :subnets)
  has_many :subnet_domains, :dependent => :destroy
  has_many :subnets, :through => :subnet_domains
  belongs_to :dns, :class_name => "SmartProxy"
  has_many :domain_parameters, :dependent => :destroy, :foreign_key => :reference_id
  has_and_belongs_to_many :users, :join_table => "user_domains"
  has_many :interfaces, :class_name => 'Nic::Base'

  accepts_nested_attributes_for :domain_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  validates_uniqueness_of :name
  validates_uniqueness_of :fullname, :allow_blank => true, :allow_nil => true
  validates_presence_of :name

  scoped_search :on => [:name, :fullname], :complete_value => true
  scoped_search :in => :domain_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :only_explicit => true, :rename => :params

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("LOWER(domains.name)")
    end
  }

  class Jail < Safemode::Jail
    allow :name, :fullname
  end

  def to_param
    name
  end

  def as_json(options={})
    super({:only => [:name, :id]}.merge(options))
  end

  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    current = User.current

    if current.allowed_to?("#{operation}_domains".to_sym)
      # If you can create domains then you can create them anywhere
      return true if operation == "create"
      # However if you are editing or destroying and you have a domain list then you are constrained
      if current.domains.empty? or current.domains.map(&:id).include? self.id
        return true
      end
    end

    errors.add :base, "You do not have permission to #{operation} this domain"
    false
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

  def lookup query
    Net::DNS.lookup query, proxy, resolver
  end

end
