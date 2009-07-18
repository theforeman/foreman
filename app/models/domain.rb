# This models a DNS domain and so represents a site.
class Domain < ActiveRecord::Base
  has_many :hosts
  validates_uniqueness_of  :name, :fullname
  validates_presence_of :dnsserver, :message => "Must specificy a DNS Server for your Site"
  validates_format_of   :dnsserver, :with => /^\S+$/, :message => "Name cannot contain spaces"
  validates_format_of   :gateway,   :with => /^\S+$/, :message => "Name cannot contain spaces"
  validates_presence_of :name, :fullname

  before_destroy :ensure_not_used

  def to_label
    name
  end

  def to_s
    name
  end

  # counts how many times a certian fact value exists in this domain
  # used mostly for statistics
  def countFact fact, value
    Host.count :joins => [:domain, :fact_values, :fact_names],
      :conditions => ["domains.name = ? and fact_names.name = ? and fact_values.value = ?", self, fact, value]
  end

end
