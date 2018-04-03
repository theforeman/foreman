class VariableLookupKey < LookupKey
  belongs_to :puppetclass, :inverse_of => :lookup_keys

  before_validation :cast_default_value
  validates :key, :uniqueness => true, :no_whitespace => true
  validates :puppetclass_id, :presence => true, :unless => ->(lk) { lk.puppetclass.present? && lk.puppetclass.new_record? }
  validate :validate_default_value, :disable_merge_overrides, :disable_avoid_duplicates, :disable_merge_default

  scoped_search :relation => :puppetclass, :on => :name, :complete_value => true, :rename => :puppetclass

  def editable_by_user?
    VariableLookupKey.authorized(:edit_external_variables).where(:id => id).exists?
  end

  def self.title_name
    "variable".freeze
  end

  def audit_class
    puppetclass
  end

  def param_class
    puppetclass
  end

  def self.humanize_class_name(options = nil)
    if options.present?
      super
    else
      "Smart variable"
    end
  end

  scope :global_parameters_for_class, lambda { |puppetclass_ids|
                                        where(:puppetclass_id => puppetclass_ids)
                                      }

  scope :smart_variables, -> { where('lookup_keys.puppetclass_id > 0').readonly(false) }
end
