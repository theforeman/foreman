# This models a DNS domain and so represents a site.
class Domain < ActiveRecord::Base
  include Authorization
  has_many :hosts
  has_many :subnets
  has_many :domain_parameters, :dependent => :destroy, :foreign_key => :reference_id
  has_and_belongs_to_many :users, :join_table => "user_domains"

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

  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    current = User.current

    if current.allowed_to?("#{operation}_domains".to_sym)
      # If you can create domains then you can create them anywhere
      return true if operation == "create"
      # However if you are editing or destroying and you have a domain list then you are contrained
      if current.domains.empty? or current.domains.map(&:id).include? self.id
        return true
      end
    end

    errors.add_to_base "You do not have permission to #{operation} this domain"
    false
  end

end

