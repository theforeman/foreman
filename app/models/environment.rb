class Environment < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  has_many :hosts
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of   :name, :with => /^[\w\d]+$/, :message => "is alphanumeric and cannot contain spaces"
  default_scope :order => 'name'
  has_many :config_templates, :through => :template_combinations, :dependent => :destroy
  has_many :template_combinations

  before_destroy Ensure_not_used_by.new(:hosts)

  def to_param
    name
  end

  # returns an hash of all puppet environments and their relative paths
  def self.puppetEnvs
    env = Hash.new
    # read puppet configuration
    Puppet.settings.parse # Check that puppet.conf has not been edited since the rack application was started
    conf = Puppet.settings.instance_variable_get(:@values)

    # query for the environments variable
    unless conf[:main][:environments].nil?
      conf[:main][:environments].split(",").each {|e| env[e.to_sym] = conf[e.to_sym][:modulepath] unless conf[e.to_sym][:modulepath].nil?}
    else
      # 0.25 doesn't require the environments variable anymore, scanning for modulepath
      conf.keys.each {|p| env[p] = conf[p][:modulepath] unless conf[p][:modulepath].nil?}
      # puppetmaster section "might" also returns the modulepath
      env.delete :main
      env.delete :puppetmasterd if env.size > 1

    end
    if env.values.compact.size == 0
      # fall back to defaults - we probably don't use environments
      env[:production] = conf[:main][:modulepath] || conf[:puppetmasterd][:modulepath] || SETTINGS[:modulepath] || Puppet[:modulepath] || "/etc/puppet/modules"
    end
    return env
  end

  # Imports all Environments and classes from Puppet modules
  def self.importClasses
    envs     = self.puppetEnvs
    pclasses = []

    # If we are deleting data then assure ourselves that we are using sensible values
    for env, paths in envs
      for path in paths.split ":"
        if Rails.env != "test"
          raise "Unable to find directory #{path} in environment #{env}" unless File.directory?(path)
        end
        pclasses << Puppetclass.scanForClasses(path)
      end
    end
    pclasses = pclasses.flatten.uniq
    raise "No puppetclasses found in #{envs.keys}" if pclasses.size == 0

    original = {}
    original[:environments]  = Environment.all.map(&:name).sort
    original[:puppetclasses] = Puppetclass.all.map(&:name).sort

    replacement = {}
    replacement[:environments]  = envs.keys.map(&:to_s).sort
    replacement[:puppetclasses] = pclasses.sort

    changes =  {:obsolete => {:environments  => original[:environments]     - replacement[:environments],
                              :puppetclasses => original[:puppetclasses]    - replacement[:puppetclasses]},
               :new       => {:environments  => replacement[:environments]  - original[:environments],
                              :puppetclasses => replacement[:puppetclasses] - original[:puppetclasses] }
               }

    # Remove any classes or environments that are in config/ignored_classes_and_environments.yml
    ignored_file = File.join(Rails.root.to_s, "config", "ignored_classes_and_environments.yml")
    if File.exist? ignored_file
      ignored = YAML.load_file ignored_file
      changes[:new][:environments]       -= ignored[:new][:environments]
      changes[:new][:puppetclasses]      -= ignored[:new][:puppetclasses]
      changes[:obsolete][:environments]  -= ignored[:obsolete][:environments]
      changes[:obsolete][:puppetclasses] -= ignored[:obsolete][:puppetclasses]
    end
    changes
  end

  # Update the environments and puppetclasses based upon the user's selection
  # It does a best attempt and can fail to perform all operations due to the
  # user requesting impossible selections. Repeat the operation if errors are
  # shown, after fixing the request.
  # +changed+ : Hash with two keys: :new and :obsolete.
  #               changed[:/new|obsolete/] is and Array of Strings
  # Returns   : Array of Strings containing all record errors
  def self.obsolete_and_new changed
    changed ||= {}
    # Fill in any missing bits in the changed datastructure
    changed.reverse_merge! :new => {}, :obsolete => {}
    changed[:new].reverse_merge!(:environments => [], :puppetclasses => []);changed[:obsolete].reverse_merge!(:environments => [], :puppetclasses => [])

    @import_errors = []
    # First we create any new puppetclasses
    for pclass in changed[:new][:puppetclasses]
      pc = Puppetclass.find_or_create_by_name pclass
      @import_errors += pc.errors unless pc.errors.empty?
    end

    puppet_envs = puppetEnvs
    # Then we create any new environments and add the associations
    for env_str in changed[:new][:environments]
      env = Environment.find_or_create_by_name env_str
      if (env.valid? and ! env.new_record?)
        pcs = Puppetclass.scanForClasses(puppet_envs[env_str.to_sym]) - changed[:obsolete][:puppetclasses]
        env.puppetclasses = names_to_instances(pcs, env)
        env.save!
      else
        @import_errors << "Unable to find or create environment #{env_str} in the foreman database"
      end
    end
    # We rebuild the puppetclass bindings for all the environments known by foreman minus the ones we will delete
    for env_str in Environment.all.map(&:name) - changed[:obsolete][:environments]
      if (env = Environment.find_by_name(env_str))
        if (path = puppet_envs[env_str.to_sym])
          pcs = Puppetclass.scanForClasses(path) - changed[:obsolete][:puppetclasses]
          # Convert the strings back into classes and add as an association
          env.puppetclasses = names_to_instances pcs,  env
          env.save!
        else
          @import_errors << "Unable to find the module paths for environment #{env_str}. This is OK if you blocked its deletion."
        end
      else
        @import_errors << "Unable to rebuild environment #{env_str}. It is not in the foreman database"
      end
    end

    # Now we delete the obsolete environments
    for env_str in changed[:obsolete][:environments]
      if (env = Environment.find_by_name env_str)
        env.puppetclasses.clear
        env.destroy
        @import_errors += env.errors.full_messages unless env.errors.empty?
      else
        @import_errors << "Unable to delete environment #{env_str}. It is not in the foreman database"
      end
    end

    # and finally delete the obsolete puppetclasses
    for pclass in changed[:obsolete][:puppetclasses]
      if (pc = Puppetclass.find_by_name(pclass))
        pc.destroy
        @import_errors += pc.errors.full_messages unless pc.errors.empty?
      else
        @import_errors << "Unable to delete puppetclass #{pclass}. It is not in the foreman database"
      end
    end
    @import_errors
  end

  def as_json(options={})
    super({:only => [:name, :id]}.merge(options))
  end

  private
  def self.names_to_instances pcs,  env
    pcs.map do |pc|
      if (theClass = Puppetclass.find_by_name(pc)).nil?
        @import_errors << "Unable to add puppetclass '#{pc}' to #{env.name}. This is OK if you have disabled its creation'"
      end
      theClass
    end.compact
  end


end
