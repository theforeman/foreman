class UserFact < ActiveRecord::Base
  belongs_to :user
  belongs_to :fact_name

  validates_inclusion_of :andor,    :in => %w{and or}
  validates_inclusion_of :operator, :in => %w{= !=  > >= < <= }
  validates_presence_of  :fact_name
  validates_presence_of  :criteria
  validates_presence_of  :user

  def initialize *args
    super *args
    operator = "="  if operator.empty?
    andor    = "or" if andor.empty?
  end

  def to_s
    n  = user.try(:name) || "Unknown user"
    fn = fact_name.try(:name) || "Unknown fact"
    "#{n}:#{fn}:#{criteria.empty? ? "Empty" : criteria}:#{operator}:#{andor}"
  end
end
