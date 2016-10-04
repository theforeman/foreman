class VariableLookupKey < LookupKey
  belongs_to :puppetclass, :inverse_of => :lookup_keys

  before_validation :cast_default_value
  validates :puppetclass, :presence => true
  validates :key, :uniqueness => true, :no_whitespace => true
  validate :validate_default_value, :disable_merge_overrides, :disable_avoid_duplicates, :disable_merge_default

  scoped_search :in => :puppetclass, :on => :name, :complete_value => true, :rename => :puppetclass

  def audit_class
    puppetclass
  end

  def param_class
    puppetclass
  end

  def self.humanize_class_name
    "Smart variable"
  end

  scope :global_parameters_for_class, lambda { |puppetclass_ids|
                                        where(:puppetclass_id => puppetclass_ids)
                                      }

  scope :smart_variables, -> { where('lookup_keys.puppetclass_id > 0').readonly(false) }
end
