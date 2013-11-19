class FactName < ActiveRecord::Base

  has_many :fact_values, :dependent => :destroy
  has_many :user_facts, :dependent => :destroy
  has_many :users, :through => :user_facts
  has_many_systems :through => :fact_values

  scope :no_timestamp_fact, lambda { where("fact_names.name <> ?",:_timestamp) }
  scope :timestamp_facts,  lambda { where(:name => :_timestamp) }

  default_scope lambda { order('fact_names.name') }

  validates :name, :uniqueness => true

  def to_param
    name
  end

end
