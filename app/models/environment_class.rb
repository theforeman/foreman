class EnvironmentClass < ActiveRecord::Base
  include AccessibleAttributes

  belongs_to :environment
  belongs_to :puppetclass
  belongs_to :puppetclass_lookup_key
  validates :puppetclass_lookup_key_id, :uniqueness => {:scope => [:environment_id, :puppetclass_id]}
  validates :puppetclass_id, :environment_id, :presence => true

  scope :parameters_for_class, lambda {|puppetclasses_ids, environment_id|
    all_parameters_for_class(puppetclasses_ids, environment_id).where(:puppetclass_lookup_keys => {:override => true})
  }

  scope :all_parameters_for_class, lambda {|puppetclasses_ids, environment_id|
    where(:puppetclass_id => puppetclasses_ids, :environment_id => environment_id).
      where('puppetclass_lookup_key_id is NOT NULL').
      includes(:puppetclass_lookup_key)
  }

  scope :used_by_other_environment_classes, lambda{|puppetclass_lookup_key_id, this_environment_class_id|
    where(:puppetclass_lookup_key_id => puppetclass_lookup_key_id).
      where("id != #{this_environment_class_id}")
  }

  # These counters key track of unique puppet class keys (parameters) across environments
  after_create do |record|
    Puppetclass.increment_counter(:global_class_params_count, self.puppetclass.id) unless self.puppetclass_lookup_key.blank? ||
      EnvironmentClass.used_by_other_environment_classes(self.puppetclass_lookup_key, self.id).count > 0
  end

  after_destroy do |record|
    Puppetclass.decrement_counter(:global_class_params_count, self.puppetclass.id) unless self.puppetclass_lookup_key.blank? ||
      EnvironmentClass.used_by_other_environment_classes(self.puppetclass_lookup_key, self.id).count > 0
  end

  def lookup_key_id=(val)
    Foreman::Deprecation.deprecation_warning("1.12", "lookup_key_id= is deprecated, please use puppetclass_lookup_key_id= instead.")
    self.puppetclass_lookup_key_id=val
  end

  def lookup_key=(val)
    Foreman::Deprecation.deprecation_warning("1.12", "lookup_key= is deprecated, please use puppetclass_lookup_key= instead.")
    self.puppetclass_lookup_key=val
  end

  #TODO move these into scopes?
  def self.is_in_any_environment(puppetclass, puppetclass_lookup_key)
    EnvironmentClass.where(:puppetclass_id => puppetclass, :puppetclass_lookup_key_id => puppetclass_lookup_key ).count > 0
  end

  def self.key_in_environment(env, puppetclass,  puppetclass_lookup_key)
    EnvironmentClass.where(:environment_id => env, :puppetclass_id => puppetclass, :puppetclass_lookup_key_id => puppetclass_lookup_key ).first
  end
end
