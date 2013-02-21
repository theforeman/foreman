class FactName < ActiveRecord::Base
  include Hostmix

  has_many :fact_values, :dependent => :destroy
  has_many :user_facts
  has_many :users, :through => :user_facts
  add_host_associations :has_many, :through => :fact_values # Host STI

  scope :no_timestamp_fact, :conditions => ["fact_names.name <> ?",:_timestamp]
  scope :timestamp_facts,   :conditions => ["fact_names.name = ?", :_timestamp]

  default_scope :order => 'LOWER(fact_names.name)'

  def to_param
    name
  end

end
