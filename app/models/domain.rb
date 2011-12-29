require "resolv"
# This models a DNS domain and so represents a site.
class Domain < ActiveRecord::Base
  include Authorization
  has_many :hosts
  has_many :hostgroups
  has_many :subnets
  belongs_to :dns, :class_name => "SmartProxy"
  has_many :domain_parameters, :dependent => :destroy, :foreign_key => :reference_id
  has_and_belongs_to_many :users, :join_table => "user_domains"

  accepts_nested_attributes_for :domain_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  validates_uniqueness_of :name
  validates_uniqueness_of :fullname, :allow_blank => true, :allow_nil => true
  validates_presence_of :name

  scoped_search :on => [:name, :fullname], :complete_value => true

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups, :subnets)
  default_scope :order => 'LOWER(domains.name)'

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
    dns = Resolv::DNS.new
    ns = dns.getresources(name, Resolv::DNS::Resource::IN::SOA).collect {|r| r.mname.to_s}
    ns = dns.getresources(name, Resolv::DNS::Resource::IN::NS).collect {|r| r.name.to_s} if ns.empty?
    ns.to_a.flatten
  end

  def resolver
    Resolv::DNS.new :search => name, :nameserver => nameservers, :ndots => 1
  end

  def proxy
    ProxyAPI::DNS.new(:url => dns.url) if dns and !dns.url.blank?
  end

  def lookup query
    Net::DNS.lookup query, proxy, resolver
  end

end
