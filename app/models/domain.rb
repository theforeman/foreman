# This models a DNS domain and so represents a site.
class Domain < ActiveRecord::Base
  has_many :hosts
  has_many :subnets
  has_many :domain_parameters, :dependent => :destroy, :foreign_key => :reference_id
  accepts_nested_attributes_for :domain_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  validates_uniqueness_of :name
  validates_uniqueness_of :fullname, :allow_blank => true, :allow_nil => true
  validates_format_of   :dnsserver, :with => /^\S+$/, :message => "Name cannot contain spaces",
    :allow_blank => true, :allow_nil => true
  validates_format_of   :gateway,   :with => /^\S+$/, :message => "Name cannot contain spaces",
    :allow_blank => true, :allow_nil => true
  validates_presence_of :name

  default_scope :order => 'name'

  before_destroy Ensure_not_used_by.new(:hosts, :subnets)

  def to_param
    name
  end

  def as_json(options={})
    super({:only => [:name, :id]}.merge(options))
  end

end

