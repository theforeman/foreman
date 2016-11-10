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
        new     = new_classes_for(env)
        old     = removed_classes_for(env)
        updated = updated_classes_for(env)
        changes['new'][env] = new if new.any?
        changes['obsolete'][env] = old if old.any?
        changes['updated'][env] = updated if updated.any?
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
      env = @environment
      new     = new_classes_for(env)
      old     = removed_classes_for(env)
      updated = updated_classes_for(env)
      changes['new'][env] = new if new.any?
      changes['obsolete'][env] = old if old.any?
      changes['updated'][env] = updated if updated.any?
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
    #rescue => e
    #  logger.error(e)
    #  [e.to_s]
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

  # This method check if the puppet class exists in this environment, and compare the class params.
  # Changes in the params are categorized to new parameters, removed parameters and parameters with a new
  # default value.
  def compare_classes(environment, klass, db_params)
    return nil unless (actual_class = actual_classes(environment)[klass])
    actual_params  = actual_class.parameters
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
    @proxy_envs ||= (proxy.environments.map(&:to_s) - ignored_environments)
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
    @foreman_classes[environment] = env.puppetclasses.includes(:lookup_keys, :class_params)
  end

  def db_classes_name(environment)
    db_classes(environment).map(&:name)
  end

  def actual_classes(environment)
    @proxy_classes[environment] ||= proxy.classes(environment).reject do |key, value|
      ignored_classes.find { |filter| filter.is_a?(Regexp) && filter =~ key }
    end
  end

  def actual_classes_name(environment)
    actual_classes(environment).keys
  end

  private

  attr_reader :proxy

  def ignored_environments
    ignored_file[:ignored] || []
  end

  def ignored_classes
    ignored_file[:filters] || []
  end

  def ignored_file
    return @ignored_file if @ignored_file
    file          = File.join(Rails.root.to_s, "config", "ignored_environments.yml")
    @ignored_file = File.exist?(file) ? YAML.load_file(file) : { }
  rescue => e
    logger.warn "Failed to parse environment ignore file: #{e}"
    @ignored_file = { }
  end

  def logger
    @logger ||= Rails.logger
  end

  def load_classes_from_json(blob)
    ActiveSupport::JSON.decode blob
  end

  def add_classes_to_foreman(env_name, klasses)
    env         = find_or_create_env env_name
    new_classes = klasses.map { |k| Puppetclass.where(:name => k[0]).first_or_create }

    new_classes.each do |new_class|
      EnvironmentClass.create! :puppetclass_id => new_class.id, :environment_id => env.id
      class_params = klasses[new_class.to_s]
      add_new_parameter(env, new_class, class_params) if class_params.any?
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
        #detach
        key_in_env.destroy
        # destroy if the key is not in any environment.
        key.destroy unless EnvironmentClass.is_in_any_environment(db_class, key)
      end
    end
  end

  def add_new_parameter(env, klass, changed_params)
    changed_params["new"].map do |param_name, value|
      param = find_or_create_puppet_class_param klass, param_name, value
      EnvironmentClass.create! :puppetclass_id => klass.id, :environment_id => env.id,
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
    Environment.where(:name => env).first || Environment.create!(:name => env)
  end

  def find_or_create_puppet_class_param(klass, param_name, value)
    klass.class_params.where(:key => param_name).first ||
      PuppetclassLookupKey.create!(:key => param_name, :required => value.nil?,
                                   :override => value.nil?, :default_value => value,
                                   :key_type => Foreman::ImporterPuppetclass.suggest_key_type(value))
  end
end
