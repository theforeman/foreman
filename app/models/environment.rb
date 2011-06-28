class Environment < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  has_many :hosts
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of   :name, :with => /^[\w\d]+$/, :message => "is alphanumeric and cannot contain spaces"
  has_many :config_templates, :through => :template_combinations, :dependent => :destroy
  has_many :template_combinations

  before_destroy Ensure_not_used_by.new(:hosts)
  default_scope :order => 'LOWER(environments.name)'

  def to_param
    name
  end

  # returns an hash of all puppet environments and their relative paths
  def self.puppetEnvs
    env = Hash.new
    unless Rails.env == "test"
      # reread puppet configuration
      Puppet.clear
      Puppet[:config] = SETTINGS[:puppetconfdir]
    end
    Puppet.parse_config # Check that puppet.conf has not been edited since the rack application was started
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
      env[:production] = conf[:main][:modulepath] || conf[:puppetmasterd][:modulepath] || Setting[:modulepath]
    end
    return env
  end

  # Imports all Environments and classes from Puppet modules
  def self.importClasses
    # Build two hashes representing the on-disk and in-database, env to classes associations
    disk_tree, db_tree = Hash.new([]), Hash.new([])

    # Create a representation of the puppet configuration where the environments are hash keys and the classes are sorted lists
    envs = self.puppetEnvs
    for env, paths in envs
      pclasses = []
      for path in paths.split ":"
        if Rails.env != "test"
          # If we are deleting data then assure ourselves that we are using sensible values
          raise "Unable to find directory #{path} in environment #{env}" unless File.directory?(path)
        end
        pclasses += Puppetclass.scanForClasses(path)
      end
      disk_tree[env.to_s] = pclasses.sort.uniq
    end

    # Create a representation of the foreman configuration where the environments are hash keys and the classes are sorted lists
    for env in Environment.all
      db_tree[env.name] = env.puppetclasses.map(&:name).sort.uniq
    end

    changes = {"new" => {}, "obsolete" => {}}
    # Generate the difference between the on-disk and database configuration
    for env in db_tree.keys
      # Show the environment if there are classes in the db that do not exist on disk
      # OR if there is no mention of the class on-disk
      surplus_db_classes = db_tree[env] - disk_tree[env]
      surplus_db_classes << "_destroy_" unless envs.has_key?(env.to_sym) # We need to distinguish between an empty and an obsolete env
      changes["obsolete"][env] = surplus_db_classes if surplus_db_classes.size > 0
    end
    for env in disk_tree.keys
      extra_disk_classes = disk_tree[env] - db_tree[env]
      # Show the environment if there are new classes compared to the db
      # OR if the environment has no puppetclasses but does not exist in the db
      changes["new"][env] = extra_disk_classes if (extra_disk_classes.size > 0 or (disk_tree[env].size == 0 and Environment.find_by_name(env).nil?))
    end

    # Remove environments that are in config/ignored_environments.yml
    ignored_file = File.join(Rails.root.to_s, "config", "ignored_environments.yml")
    if File.exist? ignored_file
      ignored = YAML.load_file ignored_file
      for env in ignored[:new]
        changes["new"].delete env
      end
      for env in ignored[:obsolete]
        changes["obsolete"].delete env
      end
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
    @import_errors = []

    # Now we add environments and associations
    for env_str in changed[:new].keys
      env = Environment.find_or_create_by_name env_str
      if (env.valid? and ! env.new_record?)
        begin
          pclasses = eval(changed[:new][env_str])
        rescue => e
          @import_errors << "Failed to eval #{changed[:new][env_str]} as an array:" + e.message
          next
        end
        for pclass in pclasses
          pc = Puppetclass.find_or_create_by_name pclass
          unless pc.errors.empty?
            @import_errors += pc.errors
          else
            env.puppetclasses << pc
          end
        end
        env.save!
      else
        @import_errors << "Unable to find or create environment #{env_str} in the foreman database"
      end
    end if changed[:new]

    # Remove the obsoleted stuff
    for env_str in changed[:obsolete].keys
      env = Environment.find_by_name env_str
      if env
        begin
          pclasses = eval(changed[:obsolete][env_str])
        rescue => e
          @import_errors << "Failed to eval #{changed[:obsolete][env_str]} as an array:" + e.message
          next
        end
        pclass = ""
        for pclass in pclasses
          unless pclass == "_destroy_"
            pc = Puppetclass.find_by_name pclass
            if pc.nil?
              @import_errors += "Unable to find puppet class #{pclass } in the foreman database"
            else
              env.puppetclasses.delete pc
              unless pc.environments.any? or pc.hosts.any?
                pc.destroy
                @import_errors += pc.errors.full_messages unless pc.errors.empty?
              end
            end
          end
        end
        if pclasses.include? "_destroy_"
          env.destroy
          @import_errors += env.errors.full_messages unless env.errors.empty?
        else
          env.save!
        end
      else
        @import_errors << "Unable to find environment #{env_str} in the foreman database"
      end
    end if changed[:obsolete]

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
