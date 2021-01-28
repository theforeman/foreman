class PuppetclassLookupKey < LookupKey
  has_many :environment_classes, :dependent => :destroy, :inverse_of => :puppetclass_lookup_key
  has_many :environments, -> { distinct }, :through => :environment_classes
  has_many :param_classes, :through => :environment_classes, :source => :puppetclass

  before_validation :check_override_selected, :if => -> { persisted? && @validation_context != :importer }

  scoped_search :relation => :param_classes, :on => :name, :rename => :puppetclass, :aliases => [:puppetclass_name], :complete_value => true
  scoped_search :relation => :environments, :on => :name, :rename => :environment, :complete_value => true, :only_explicit => true

  scope :smart_class_parameters_for_class, lambda { |puppetclass_ids, environment_id|
                                             joins(:environment_classes).where(:environment_classes => {:puppetclass_id => puppetclass_ids, :environment_id => environment_id})
                                           }

  scope :parameters_for_class, lambda { |puppetclass_ids, environment_id|
                                 override.smart_class_parameters_for_class(puppetclass_ids, environment_id)
                               }

  scope :smart_class_parameters, -> { joins(:environment_classes).readonly(false) }

  def editable_by_user?
    PuppetclassLookupKey.authorized(:edit_external_parameters).where(:id => id).exists?
  end

  def param_class
    param_classes.first
  end

  def audit_class
    param_class
  end

  def cast_default_value
    super unless omit
    true
  end

  def validate_default_value
    super unless omit
    true
  end

  def puppet?
    true
  end

  def check_override_selected
    return if (changed - ['description', 'override']).empty?
    return if override?
    errors.add(:override, _("must be true to edit the parameter"))
  end

  def self.humanize_class_name
    "Smart class parameter"
  end
end
