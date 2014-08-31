class FactName < ActiveRecord::Base
  SEPARATOR = '::'

  validates_lengths_from_database
  has_many :fact_values, :dependent => :destroy
  has_many :user_facts, :dependent => :destroy
  has_many :users, :through => :user_facts
  has_many_hosts :through => :fact_values

  scope :no_timestamp_fact, lambda { where("fact_names.name <> ?",:_timestamp) }
  scope :timestamp_facts,  lambda { where(:name => :_timestamp) }
  scope :with_parent_id, lambda { |find_ids|
    conds = []; binds = []
    [find_ids].flatten.each do |find_id|
      conds.push "(fact_names.ancestry LIKE '%/?' OR ancestry = '?')"
      binds.push find_id, find_id
    end
    where(conds.join(' OR '), *binds)
  }

  default_scope lambda { order('fact_names.name') }

  validates :name, :uniqueness => { :scope => :type }

  before_save :set_name, :if => Proc.new { |fact| fact.short_name.blank? }

  has_ancestry

  def to_param
    name
  end

  def set_name
    self.short_name = self.name.split(SEPARATOR).last
  end

end
