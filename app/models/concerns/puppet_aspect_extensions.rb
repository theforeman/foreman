module PuppetAspectExtensions
  extend ActiveSupport::Concern

  included do
    has_one :puppet_aspect, :class_name => 'PuppetAspect', :foreign_key => :host_id, :inverse_of => :host
    has_one :puppet_proxy, :class_name => 'SmartProxy', :through => :puppet_aspect
    has_one :puppet_ca_proxy, :class_name => 'SmartProxy', :through => :puppet_aspect
    has_many :host_classes, :foreign_key => :host_id
    has_many :puppetclasses, :through => :host_classes, :dependent => :destroy
    has_many :group_puppetclasses, :through => :config_groups, :source => :puppetclasses
    accepts_nested_attributes_for :puppet_aspect
    alias_method :puppet_aspect_attributes, :puppet_aspect

    scoped_search :in => :puppet_proxy, :on => :name, :complete_value => true, :rename => :puppetmaster
    scoped_search :in => :puppet_ca_proxy, :on => :name,    :complete_value => true, :rename => :puppet_ca
    scoped_search :in => :puppetclasses, :on => :name, :complete_value => true, :rename => :class, :only_explicit => true, :operators => ['= ', '~ '], :ext_method => :search_by_puppetclass
    before_validation :set_hostgroup_puppet_defaults

    after_save :update_hostgroups_puppetclasses, :if => :hostgroup_id_changed?
    after_validation :ensure_class_associations
  end

  module ClassMethods
    def search_by_puppetclass(key, operator, value)
      conditions    = sanitize_sql_for_conditions(["puppetclasses.name #{operator} ?", value_to_sql(operator, value)])
      config_group_ids = ConfigGroup.where(conditions).joins(:puppetclasses).pluck('config_groups.id')
      host_ids         = Host.authorized(:view_hosts, Host).where(conditions).joins(:puppetclasses).uniq.map(&:id)
      host_ids        += HostConfigGroup.where(:host_type => 'Host::Base').where(:config_group_id => config_group_ids).pluck(:host_id)
      hostgroups       = Hostgroup.unscoped.with_taxonomy_scope.where(conditions).joins(:puppetclasses)
      hostgroups      += Hostgroup.unscoped.with_taxonomy_scope.joins(:host_config_groups).where("host_config_groups.config_group_id IN (#{config_group_ids.join(',')})") if config_group_ids.any?
      hostgroup_ids    = hostgroups.map(&:subtree_ids).flatten.uniq

      opts  = ''
      opts += "hosts.id IN(#{host_ids.join(',')})"            unless host_ids.blank?
      opts += " OR "                                          unless host_ids.blank? || hostgroup_ids.blank?
      opts += "hostgroups.id IN(#{hostgroup_ids.join(',')})"  unless hostgroup_ids.blank?
      opts  = "hosts.id < 0"                                  if host_ids.blank? && hostgroup_ids.blank?
      {:conditions => opts, :include => :hostgroup}
    end
  end

  module InstanceMethods
    # this method accepts a puppets external node yaml output and generate a node in our setup
    # it is assumed that you already have the node (e.g. imported by one of the rack tasks)
    def importNode(nodeinfo)
      myklasses= []
      # puppet classes
      nodeinfo["classes"].each do |klass|
        if (pc = Puppetclass.find_by_name(klass))
          myklasses << pc
        else
          error = _("Failed to import %{klass} for %{name}: doesn't exists in our database - ignoring") % { :klass => klass, :name => name }
          logger.warn error
          $stdout.puts error
        end
        self.puppetclasses = myklasses
      end

      # parameters are a bit more tricky, as some classifiers provide the facts as parameters as well
      # not sure what is puppet priority about it, but we ignore it if has a fact with the same name.
      # additionally, we don't import any non strings values, as puppet don't know what to do with those as well.

      myparams = self.info["parameters"]
      nodeinfo["parameters"].each_pair do |param,value|
        next if fact_names.exists? :name => param
        next unless value.is_a?(String)

        # we already have this parameter
        next if myparams.has_key?(param) and myparams[param] == value

        unless (hp = self.host_parameters.create(:name => param, :value => value))
          logger.warn "Failed to import #{param}/#{value} for #{name}: #{hp.errors.full_messages.join(", ")}"
          $stdout.puts $ERROR_INFO
        end
      end

      self.clear_host_parameters_cache!
      self.save
    end

    # checks if the host association is a valid association for this host
    def ensure_class_associations
      status = true

      self.puppetclasses.select("puppetclasses.id,puppetclasses.name").uniq.each do |e|
        unless self.puppet_aspect.environment.puppetclasses.map(&:id).include?(e.id)
          errors.add(:puppetclasses, _("%{e} does not belong to the %{environment} environment") % { :e => e, :environment => puppet_aspect.environment })
          status = false
        end
      end if self.puppet_aspect.try(:environment)

      status
    end

    def update_hostgroups_puppetclasses
      Hostgroup.find(hostgroup_id_was).update_puppetclasses_total_hosts if hostgroup_id_was.present?
      Hostgroup.find(hostgroup_id).update_puppetclasses_total_hosts     if hostgroup_id.present?
    end

    def set_hostgroup_puppet_defaults
      self.puppet_aspect.set_hostgroup_defaults if puppet_aspect
    end
  end
end
