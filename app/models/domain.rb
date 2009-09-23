# This models a DNS domain and so represents a site.
class Domain < ActiveRecord::Base
  has_many :hosts
  has_many :subnets
  has_many :domain_parameters, :dependent => :destroy
  validates_uniqueness_of :name
  validates_uniqueness_of :fullname, :allow_blank => true, :allow_nil => true
  validates_format_of   :dnsserver, :with => /^\S+$/, :message => "Name cannot contain spaces",
    :allow_blank => true, :allow_nil => true
  validates_format_of   :gateway,   :with => /^\S+$/, :message => "Name cannot contain spaces",
    :allow_blank => true, :allow_nil => true
  validates_presence_of :name

  before_destroy :ensure_not_used

  def to_label
    name
  end

  def to_s
    to_label
  end

  # counts how many times a certian fact value exists in this domain
  # used mostly for statistics
  def countFact fact, value
    Host.count :joins => [:domain, :fact_values, :fact_names],
      :conditions => ["domains.name = ? and fact_names.name = ? and fact_values.value = ?", self, fact, value]
  end

end
