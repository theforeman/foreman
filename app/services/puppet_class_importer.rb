class PuppetClassImporter
  def initialize(args = { })
    @foreman_classes = { }
    @proxy_classes   = { }
    @environment = args[:env]

    if args[:proxy]
      @proxy = args[:proxy]
    elsif args[:url]
      @proxy = ProxyAPI::Puppet.new(:url => args[:url])
    else
      url = SmartProxy.with_features("Puppet").first.try(:url)
      raise "Can't find a valid Proxy with a Puppet feature" if url.blank?
      @proxy = ProxyAPI::Puppet.new(:url => url)
    end
  end

  # return changes hash, currently exists to keep compatibility with importer html
  def changes
    changes = { 'new' => { }, 'obsolete' => { }, 'updated' => { }, 'ignored' => { } }

    if @environment.nil?
      actual_environments.each do |env|
        changes_for_environment(env, changes)
      end

      old_environments.each do |env|
        changes['obsolete'][env] ||= []
        changes['obsolete'][env] << "_destroy_" unless actual_environments.include?(env)
      end

      ignored_environments.each do |env|
        changes['ignored'][env] ||= []
        changes['ignored'][env] << '_ignored_'
      end
    else
      changes_for_environment(@environment, changes)
    end

    changes
  end

  # Adds class changes of an environment to a changes hash in new, obsolete and updated
  #
  # Params:
  #  * +environment+: {String} of environments name
  #  * +changes+: {Hash} to add changes to
  #
  def changes_for_environment(environment, changes)
    new_classes     = new_classes_for(environment)
    old_classes     = removed_classes_for(environment)
    updated_classes = updated_classes_for(environment)
    ignored_classes = ignored_classes_for(environment)
    changes['new'][environment] = new_classes if new_classes.any?
    changes['obsolete'][environment] = old_classes if old_classes.any?
    changes['updated'][environment] = updated_classes if updated_classes.any?
    changes['ignored'][environment] = ignored_classes if ignored_classes.any?
  end

  # Update the environments and puppetclasses based upon the user's selection
  # It does a best attempt and can fail to perform all operations due to the
  # user requesting impossible selections. Repeat the operation if errors are
  # shown, after fixing the request.
  # +changed+ : Hash with two keys: :new and :obsolete.
  #               changed[:/new|obsolete/] is and Array of Strings
  # Returns   : Array of Strings containing all record errors
  def obsolete_and_new(changes = { })
    return if changes.empty?
    changes.values.map(&:keys).flatten.uniq.each do |env_name|
      if changes['new'] && changes['new'][env_name].try(:>, '') # we got new classes
        add_classes_to_foreman(env_name, JSON.parse(changes['new'][env_name]))
      end
      if changes['obsolete'] && changes['obsolete'][env_name].try(:>, '') # we need to remove classes
        remove_classes_from_foreman(env_name, JSON.parse(changes['obsolete'][env_name]))
      end
      if changes['updated'] && changes['updated'][env_name].try(:>, '') # we need to update classes
        update_classes_in_foreman(env_name, JSON.parse(changes['updated'][env_name]))
      end
    end
    []
  rescue => e
    Foreman::Logging.exception('Failed to calculate obsolete and new', e)
    [e.to_s]
  end

  # Returns all classes for a given environment
  #
  # Params:
  #  * +environment+: {String} containing the name of the environment
  #
  def proxy_classes_for(environment)
    @proxy_classes[environment] ||= proxy.classes(environment)
  end

  def new_classes_for(environment)
    old_classes = db_classes_name(environment)
    HashWithIndifferentAccess[
      actual_classes(environment).values.map do |actual_class|
        [actual_class.to_s, { "new" => actual_class.parameters }] unless old_classes.include?(actual_class.to_s)
      end.compact
    ]
  end

  def removed_classes_for(environment)
    db_classes_name(environment) - actual_classes_name(environment)
  end

  def updated_classes_for(environment)
    return [] unless db_environments.include?(environment) && actual_environments.include?(environment)
    HashWithIndifferentAccess[
      db_classes(environment).map do |db_class|
        params = EnvironmentClass.all_parameters_for_class(db_class.id, find_or_create_env(environment).id).map(&:puppetclass_lookup_key)
        compare_classes(environment, db_class.name, params)
      end.compact
    ]
  end

  # Gives back the classes ignored for a given environment
  #
  # Params:
  #  * +environment+: {String} name of the environment
  #
  def ignored_classes_for(environment)
    proxy_classes_for(environment).keys.select do |class_name|
      ignored_class?(class_name)
    end
  end

  # Returns true when the class name matches any pattern in ignored_classes
  #
  # Params:
  #  * +class_name+: {String} containing the class to be checked
  #
  def ignored_class?(class_name)
    ignored_classes.any? do |filter|
      filter.is_a?(Regexp) && filter =~ class_name
    end
  end

  # This method check if the puppet class exists in this environment, and compare the class params.
  # Changes in the params are categorized to new parameters, removed parameters and parameters with a new
  # default value.
  def compare_classes(environment, klass, db_params)
    return nil unless (actual_class = actual_classes(environment)[klass])
    actual_params = actual_class.parameters
    db_param_names = db_params.map(&:to_s)

    param_changes = { }
    old           = db_param_names - actual_params.keys
    param_changes['obsolete'] = old if old.any?
    new = actual_params.reject { |key, value| db_param_names.include?(key) }
    param_changes['new'] = new if new.any?
    updated = updated_classes(actual_params, db_params)
    param_changes['updated'] = updated if updated.any?
    [klass, param_changes] if param_changes.keys.any?
  end

  def updated_classes(actual_params, db_params)
    updated = { }
    db_params.map do |p|
      param_name = p.to_s
      if !p.override && actual_params.has_key?(param_name) && actual_params[param_name] != p.default_value
        updated[param_name] = actual_params[param_name]
      end
    end
    updated
  end

  def db_environments
    @foreman_envs ||= (Environment.pluck('environments.name') - ignored_environments)
  end

  def actual_environments
    (proxy_environments & (User.current.visible_environments + to_be_created_environments)) - ignored_environments
  end

  def proxy_environments
    proxy.environments.map(&:to_s)
  end

  def to_be_created_environments
    proxy_environments - Environment.unscoped.where(:name => proxy_environments).pluck(:name)
  end

  def new_environments
    actual_environments - db_environments
  end

  def old_environments
    db_environments - actual_environments
  end

  def db_classes(environment)
    return @foreman_classes[environment] if @foreman_classes[environment]
    return [] unless (env = Environment.find_by_name(environment))
    @foreman_classes[environment] = env.puppetclasses.includes(:class_params)
  end

  def db_classes_name(environment)
    db_classes(environment).map(&:name)
  end

  # Returns an {Hash} of puppet class names without ignored classes
  #
  # Params:
  #  * +environment+: {String} containing the environment name
  #
  def actual_classes(environment)
    proxy_classes_for(environment).reject { |key, _| ignored_class? key }
  end

  def actual_classes_name(environment)
    actual_classes(environment).keys
  end

  def ignored_boolean_environment_names?
    ignored_environments.any? { |item| item.is_a?(TrueClass) || item.is_a?(FalseClass) }
  end

  private

  attr_reader :proxy

  def ignored_environments
    ignored_file[:ignored] || []
  end

  def ignored_classes
    ignored_file[:filters] || []
  end

  def ignored_file_path
    File.join(Rails.root.to_s, "config", "ignored_environments.yml")
  end

  def load_ignored_file
    File.exist?(ignored_file_path) ? YAML.load_file(ignored_file_path) : { }
  end

  def ignored_file
    @ignored_file ||= load_ignored_file
  rescue => e
    Foreman::Logging.exception('Failed to parse environment ignore file', e)
    @ignored_file = { }
  end

  def logger
    @logger ||= Rails.logger
  end

  def load_classes_from_json(blob)
    ActiveSupport::JSON.decode blob
  end

  def add_classes_to_foreman(env_name, klasses)
    env = find_or_create_env env_name

    klasses.each do |klass_name, klass_params|
      puppetclass = find_or_create_puppetclass_for_env(klass_name, env)
      add_new_parameter(env, puppetclass, klass_params) if klass_params.any?
    end
  end

  def update_classes_in_foreman(environment, klasses)
    env        = find_or_create_env(environment)
    db_classes = env.puppetclasses.where(:name => klasses.keys)
    db_classes.each do |db_class|
      changed_params = klasses[db_class.to_s]
      # Add new parameters
      add_new_parameter(env, db_class, changed_params) if changed_params["new"]
      # Unbind old parameters
      remove_parameter(env, db_class, changed_params) if changed_params["obsolete"]
      # Update parameters (affects solely the default value)
      update_parameter(db_class, changed_params) if changed_params["updated"]
    end
  end

  def update_parameter(db_class, changed_params)
    changed_params["updated"].each do |param_name, value|
      key = db_class.class_params.find_by_key param_name
      if key.override == false
        key.default_value = value
        key.key_type = nil
        key.validator_type = nil
        key.save!(:context => :importer)
      end
    end
  end

  def remove_parameter(env, db_class, changed_params)
    changed_params["obsolete"].each do |param_name, value|
      key        = db_class.class_params.find_by_key param_name
      key_in_env = EnvironmentClass.key_in_environment(env, db_class, key)

      if key && key_in_env
        # detach
        key_in_env.destroy
        # destroy if the key is not in any environment.
        key.destroy unless EnvironmentClass.is_in_any_environment(db_class, key)
      end
    end
  end

  def add_new_parameter(env, klass, changed_params)
    changed_params["new"].map do |param_name, value|
      param = find_or_create_puppet_class_param klass, param_name, value
      EnvironmentClass.find_or_create_by! :puppetclass_id => klass.id, :environment_id => env.id,
        :puppetclass_lookup_key_id => param.id
    end
  end

  def remove_classes_from_foreman(env_name, klasses)
    env     = find_or_create_env(env_name)
    classes = find_existing_foreman_classes(klasses)
    env.puppetclasses.destroy classes
    # remove all old classes from hosts
    HostClass.joins(:host).where(:hosts => { :environment_id => env.id }, :puppetclass_id => classes).destroy_all
    if klasses.include? '_destroy_'
      # we can't guaranty that the env would be removed as it might have hosts attached to it.
      env.destroy
    end
    # remove all klasses that have no environment now
    classes.not_in_any_environment.destroy_all
  end

  def find_existing_foreman_classes(klasses = [])
    Puppetclass.where(:name => klasses)
  end

  def find_or_create_env(env)
    user_visible_environment(env) || Environment.create!(:name => env,
                                                                 :organizations => User.current.my_organizations,
                                                                 :locations => User.current.my_locations)
  end

  def user_visible_environment(env)
    return unless User.current.visible_environments.include? env
    Environment.unscoped.find_by :name => env
  end

  def find_or_create_puppet_class_param(klass, param_name, value)
    klass.class_params.where(:key => param_name).first ||
      PuppetclassLookupKey.create!(:key => param_name, :default_value => value,
                                   :key_type => Foreman::ImporterPuppetclass.suggest_key_type(value))
  end

  # look for Puppet class in all scopes to make sure we do not try to create a new record
  # with a name that already exists and hit the uniqueness constraint on name
  def find_or_create_puppetclass_for_env(klass_name, env)
    puppetclass = Puppetclass.find_or_initialize_by(name: klass_name)
    puppetclass.environment_classes.find_or_initialize_by(environment_id: env.id)
    puppetclass.save
    raise Foreman::Exception.new('Failed to create Puppetclass: %s', puppetclass.errors.full_messages.to_sentence) unless puppetclass.errors.empty?
    puppetclass
  end
end
