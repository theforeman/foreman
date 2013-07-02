require 'puppet/rails'

class UserFact < ActiveRecord::Base
  belongs_to :user
  belongs_to :fact_name

  validates_inclusion_of :andor,    :in => %w{and or}
  validates_inclusion_of :operator, :in => %w{= !=  > >= < <= }
  validates_presence_of  :fact_name
  validates_presence_of  :criteria
  validates_presence_of  :user
  before_validation :set_defaults

  def to_s
    n  = user.try(:name) || _("Unknown user")
    fn = fact_name.try(:name) || _("Unknown fact")
    "#{n}:#{fn}:#{criteria.empty? ? "Empty" : criteria}:#{operator}:#{andor}"
  end

  private
  def set_defaults
    self.operator ||= "="
    self.andor    ||= "or"
  end

end
