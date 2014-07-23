class UserFact < ActiveRecord::Base
  belongs_to :user
  belongs_to :fact_name

  validates_lengths_from_database
  validates :andor, :inclusion => {:in => %w{and or}}
  validates :operator, :inclusion => {:in => %w{= !=  > >= < <= }}
  validates :fact_name, :criteria, :user, :presence => true
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
