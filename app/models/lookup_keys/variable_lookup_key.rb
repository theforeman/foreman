class VariableLookupKey < LookupKey
  belongs_to :puppetclass, :inverse_of => :lookup_keys, :counter_cache => :variable_lookup_keys_count
  attr_accessible :puppetclass_id, :puppetclass

  validates :puppetclass, :presence => true
  validates :key, :uniqueness => true

  scoped_search :in => :puppetclass, :on => :name, :complete_value => true, :rename => :puppetclass

  def audit_class
    puppetclass
  end

  def param_class
    puppetclass
  end

  scope :global_parameters_for_class, lambda { |puppetclass_ids|
                                        where(:puppetclass_id => puppetclass_ids)
                                      }

  scope :smart_variables, -> { where('lookup_keys.puppetclass_id > 0').readonly(false) }
end
