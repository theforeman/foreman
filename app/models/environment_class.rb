class EnvironmentClass < ActiveRecord::Base
  belongs_to :environment
  belongs_to :puppetclass
  belongs_to :lookup_key
  validates :lookup_key_id, :uniqueness => {:scope => [:environment_id, :puppetclass_id]}
  validates :puppetclass_id, :environment_id, :presence => true

  scope :parameters_for_class, lambda {|puppetclasses_ids, environment_id|
    all_parameters_for_class(puppetclasses_ids, environment_id).where(:lookup_keys => {:override => true})
  }

  scope :all_parameters_for_class, lambda {|puppetclasses_ids, environment_id|
    where(:puppetclass_id => puppetclasses_ids, :environment_id => environment_id).
      where('lookup_key_id is NOT NULL').
      includes(:lookup_key)
  }

  scope :used_by_other_environment_classes, lambda{|lookup_key_id, this_environment_class_id|
    where(:lookup_key_id => lookup_key_id).
      where("id != #{this_environment_class_id}")
  }

  # These counters key track of unique puppet class keys (parameters) across environments
  after_create { |record|
    Puppetclass.increment_counter(:global_class_params_count, self.puppetclass.id) unless self.lookup_key.blank? ||
      EnvironmentClass.used_by_other_environment_classes(self.lookup_key, self.id).count > 0
  }

  after_destroy { |record|
    Puppetclass.decrement_counter(:global_class_params_count, self.puppetclass.id) unless self.lookup_key.blank? ||
      EnvironmentClass.used_by_other_environment_classes(self.lookup_key, self.id).count > 0
  }

  #TODO move these into scopes?
  def self.is_in_any_environment(puppetclass, lookup_key)
    EnvironmentClass.where(:puppetclass_id => puppetclass, :lookup_key_id => lookup_key ).count > 0
  end

  def self.key_in_environment(env, puppetclass,  lookup_key)
    EnvironmentClass.where(:environment_id => env, :puppetclass_id => puppetclass, :lookup_key_id => lookup_key ).first
  end
end
