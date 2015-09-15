class PuppetclassLookupKey < LookupKey
  has_many :environment_classes, :dependent => :destroy
  has_many :environments, -> { uniq }, :through => :environment_classes
  has_many :param_classes, :through => :environment_classes, :source => :puppetclass

  scoped_search :in => :param_classes, :on => :name, :rename => :puppetclass, :complete_value => true

  scope :smart_class_parameters_for_class, lambda { |puppetclass_ids, environment_id|
                                             joins(:environment_classes).where(:environment_classes => {:puppetclass_id => puppetclass_ids, :environment_id => environment_id})
                                           }

  scope :parameters_for_class, lambda { |puppetclass_ids, environment_id|
                                 override.smart_class_parameters_for_class(puppetclass_ids,environment_id)
                               }

  scope :smart_class_parameters, -> { joins(:environment_classes).readonly(false) }

  attr_accessible :environments, :environment_ids, :environment_names,
    :environment_classes, :environment_classes_ids, :environment_classes_names,
    :param_classes, :param_classes_ids, :param_classes_names, :required

  def param_class
    param_classes.first
  end

  def audit_class
    param_class
  end

  def cast_default_value
    super unless use_puppet_default
    true
  end

  def validate_default_value
    super unless use_puppet_default
    true
  end

  def puppet?
    true
  end
end
