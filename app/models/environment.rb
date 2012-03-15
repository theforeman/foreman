class Environment < ActiveRecord::Base
  has_and_belongs_to_many :puppetclasses
  has_many :hosts
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name, :with => /^[\w\d]+$/, :message => "is alphanumeric and cannot contain spaces"
  has_many :config_templates, :through => :template_combinations, :dependent => :destroy
  has_many :template_combinations

  before_destroy EnsureNotUsedBy.new(:hosts)
  default_scope :order => 'LOWER(environments.name)'

  scoped_search :on => :name, :complete_value => :true

  def to_param
    name
  end

  class << self

    # returns an hash of all puppet environments and their relative paths
    def puppetEnvs proxy = nil
      #TODO: think of a better way to model multiple puppet proxies
      url = (proxy || find_a_usable_proxy).try(:url)
      raise "Can't find a valid Foreman Proxy with a Puppet feature" if url.blank?
      proxy = ProxyAPI::Puppet.new :url => url
      HashWithIndifferentAccess[proxy.environments.map { |e| [e, proxy.classes(e)] }]
    end

    # Imports all Environments and classes from Puppet modules
    def importClasses
      # Build two hashes representing the on-disk and in-database, env to classes associations
      # Create a representation of the puppet configuration where the environments are hash keys and the classes are sorted lists
      disk_tree         = puppetEnvs
      disk_tree.default = []

      # Create a representation of the foreman configuration where the environments are hash keys and the classes are sorted lists
      db_tree           = HashWithIndifferentAccess[Environment.all.map { |e| [e.name, e.puppetclasses.select(:name).map(&:name)] }]
      db_tree.default   = []

      changes = { "new" => { }, "obsolete" => { } }
      # Generate the difference between the on-disk and database configuration
      for env in db_tree.keys
        # Show the environment if there are classes in the db that do not exist on disk
        # OR if there is no mention of the class on-disk
        surplus_db_classes = db_tree[env] - disk_tree[env]
        surplus_db_classes << "_destroy_" unless disk_tree.has_key?(env) # We need to distinguish between an empty and an obsolete env
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
    def obsolete_and_new changed
      changed        ||= { }
      @import_errors = []

      # Now we add environments and associations
      for env_str in changed[:new].keys
        env = Environment.find_or_create_by_name env_str
        if env.valid? and !env.new_record?
          begin
            pclasses = eval(changed[:new][env_str])
          rescue => e
            @import_errors << "Failed to eval #{changed[:new][env_str]} as an array:" + e.message
            next
          end
          for pclass in pclasses
            pc = Puppetclass.find_or_create_by_name pclass
            if pc.errors.empty?
              env.puppetclasses << pc
            else
              @import_errors += pc.errors.map(&:to_s)
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
                @import_errors << "Unable to find puppet class #{pclass} in the foreman database"
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

    private

    def find_a_usable_proxy
      if (f = Feature.where(:name => "Puppet"))
        if !f.empty? and (proxies=f.first.smart_proxies)
          return proxies.first unless proxies.empty?
        end
      end
      nil
    end
  end

  def as_json(options={ })
    options ||= { }
    super({ :only => [:name, :id] }.merge(options))
  end

end
