class EnvironmentClass < ActiveRecord::Base
  belongs_to :environment
  belongs_to :puppetclass
  belongs_to :lookup_key
  validates_uniqueness_of :lookup_key_id,  :scope => [:environment_id, :puppetclass_id]
  validates_presence_of :puppetclass_id, :environment_id

  scope :parameters_for_class, lambda {|puppetclasses_ids, environment_id|
      all_parameters_for_class(puppetclasses_ids, environment_id).where(:lookup_keys => {:override => true})
  }
  scope :all_parameters_for_class, lambda {|puppetclasses_ids, environment_id|
    where(:puppetclass_id => puppetclasses_ids, :environment_id => environment_id).
      where('lookup_key_id is NOT NULL').
      includes(:lookup_key)
  }

  #TODO move these into scopes?
  def self.is_in_any_environment(puppetclass, lookup_key)
    EnvironmentClass.where(:puppetclass_id => puppetclass, :lookup_key_id => lookup_key ).count > 0
  end

  def self.key_in_environment(env, puppetclass,  lookup_key)
    EnvironmentClass.where(:environment_id => env, :puppetclass_id => puppetclass, :lookup_key_id => lookup_key ).first
  end
end
