class FactName < ActiveRecord::Base

  has_many :fact_values, :dependent => :destroy
  has_many :user_facts, :dependent => :destroy
  has_many :users, :through => :user_facts
  has_many_hosts :through => :fact_values

  scope :no_timestamp_fact, :conditions => ["fact_names.name <> ?",'_timestamp']
  scope :timestamp_facts,   :conditions => ["fact_names.name = ?", '_timestamp']

  default_scope :order => 'fact_names.name'

  validate :name, :uniqueness => true

  def to_param
    name
  end

end
