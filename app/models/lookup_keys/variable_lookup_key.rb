class VariableLookupKey < LookupKey
  belongs_to :puppetclass, :inverse_of => :lookup_keys

  validates :puppetclass, :presence => true
  validates :key, :uniqueness => true, :no_whitespace => true
  validate :disable_merge_overrides, :disable_avoid_duplicates, :disable_merge_default

  scoped_search :relation => :puppetclass, :on => :name, :complete_value => true, :rename => :puppetclass

  def editable_by_user?
    VariableLookupKey.authorized(:edit_external_variables).where(:id => id).exists?
  end

  def audit_class
    puppetclass
  end

  def param_class
    puppetclass
  end

  def override
    true
  end

  def self.humanize_class_name
    "Smart variable"
  end

  scope :global_parameters_for_class, lambda { |puppetclass_ids|
                                        where(:puppetclass_id => puppetclass_ids)
                                      }

  scope :smart_variables, -> { where('lookup_keys.puppetclass_id > 0').readonly(false) }
end
