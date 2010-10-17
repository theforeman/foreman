class Environment < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  has_many :hosts
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of   :name, :with => /^[\w\d]+$/, :message => "is alphanumeric and cannot contain spaces"
  default_scope :order => 'name'

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
        raise "Unable to find directory #{path} in environment #{env}" unless File.directory? path
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

    return :obsolete => {:environments => [original[:environments]].flatten - [replacement[:environments]].flatten,      :puppetclasses => [original[:puppetclasses]].flatten - [replacement[:puppetclasses]].flatten},
           :new      => {:environments => [replacement[:environments]].flatten      - [original[:environments]].flatten, :puppetclasses => [replacement[:puppetclasses]].flatten      - [original[:puppetclasses]].flatten }

  end

  # Update the environments and puppetclasses based upon the user's selection
  # +changed+ : Hash with two keys: :new and :obsolete.
  #               changed[:/new|obsolete/] is and Array of Strings
  # Returns   : String containing all record error strings joined with <br/>
  def self.obsolete_and_new changed
    changed ||= {}
    # Fill in any missing bits in the changed datastructure
    changed.reverse_merge! :new => {}, :obsolete => {}
    changed[:new].reverse_merge!(:environments => [], :puppetclasses => []);changed[:obsolete].reverse_merge!(:environments => [], :puppetclasses => [])

    # First we create any new puppetclasses
    for pclass in changed[:new][:puppetclasses]
      Puppetclass.find_or_create_by_name pclass
    end

    # Then we create any new environments and attach the puppetclasses
    for env, paths in self.puppetEnvs
      if changed[:new][:environments].include? env.to_s
        env = Environment.find_or_create_by_name env.to_s
        for path in paths.split ":"
          pcs = Array.new
          for modulepath in path.split(":")
            pcs = Puppetclass.scanForClasses(modulepath)
            # We do not bind classes to be deleted to the new environment
            pcs -= changed[:obsolete][:puppetclasses]
            env.puppetclasses = pcs.map{|pc| Puppetclass.find_by_name(pc)}
          end
        end
      end
    end

    # We now delete the obsolete puppetclasses
    errors = ""
    for pclass in changed[:obsolete][:puppetclasses]
      (pc = Puppetclass.find_by_name(pclass)).destroy
      pc.errors.each_full {|msg| errors += "#{msg}<br/>"} unless pc.errors.empty?
    end

    # Now finally remove the old environements
    for environment in changed[:obsolete][:environments]
      (env = Environment.find_by_name(environment)).destroy
      env.errors.each_full {|msg| errors += "#{msg}<br/>"} unless env.errors.empty?
    end
    errors
  end

  def as_json(options={})
    super({:only => [:name, :id]}.merge(options))
  end


end
