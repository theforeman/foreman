class ConfigTemplate < ActiveRecord::Base
  include Authorizable
  include Taxonomix

  validates_lengths_from_database
  audited :allow_mass_assignment => true
  self.auditing_enabled = !Foreman.in_rake?('db:migrate')
  attr_accessible :name, :template, :template_kind, :template_kind_id, :snippet, :template_combinations_attributes,
                  :operatingsystems, :operatingsystem_ids, :audit_comment, :location_ids, :organization_ids, :locked,
                  :vendor, :default
  validates :name, :presence => true, :uniqueness => true
  validates :template, :presence => true
  validates :template_kind_id, :presence => true, :unless => Proc.new {|t| t.snippet }
  validate :template_changes, :if => lambda { |template| (template.locked? || template.locked_changed?) && !Foreman.in_rake? }
  before_destroy :check_if_template_is_locked
  before_destroy EnsureNotUsedBy.new(:hostgroups, :environments, :os_default_templates)
  has_many :hostgroups, :through => :template_combinations
  has_many :environments, :through => :template_combinations
  has_many :template_combinations, :dependent => :destroy
  belongs_to :template_kind
  accepts_nested_attributes_for :template_combinations, :allow_destroy => true, :reject_if => lambda {|tc| tc[:environment_id].blank? and tc[:hostgroup_id].blank? }
  has_and_belongs_to_many :operatingsystems
  has_many :os_default_templates
  before_save :set_os_hash, :set_operating_systems, :check_for_snippet_associations, :remove_trailing_chars
  serialize :os_hash, Hash
  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("config_templates.name")
    end
  }

  scoped_search :on => :name,    :complete_value => true, :default_order => true
  scoped_search :on => :locked,  :complete_value => true, :complete_value => {:true => true, :false => false}
  scoped_search :on => :snippet, :complete_value => true, :complete_value => {:true => true, :false => false}
  scoped_search :on => :template

  scoped_search :in => :operatingsystems, :on => :name, :rename => :operatingsystem, :complete_value => true
  scoped_search :in => :environments,     :on => :name, :rename => :environment,     :complete_value => true
  scoped_search :in => :hostgroups,       :on => :name, :rename => :hostgroup,       :complete_value => true
  scoped_search :in => :template_kind,    :on => :name, :rename => :kind,            :complete_value => true

  class Jail < Safemode::Jail
    allow :name
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def clone
    self.deep_clone(:include => [:operatingsystems, :organizations, :locations],
                    :except  => [:name, :locked, :default, :vendor])
  end

  # TODO: review if we can improve SQL
  def self.template_ids_for(hosts)
    hosts.with_os.map do |host|
      host.configTemplate.try(:id)
    end.uniq.compact
  end

  def self.find_template opts = {}
    raise ::Foreman::Exception.new(N_("Must provide template kind")) unless opts[:kind]
    raise ::Foreman::Exception.new(N_("Must provide an operating systems")) unless opts[:operatingsystem_id]

    # first filter valid templates to our OS and requested template kind.
    templates = ConfigTemplate.joins(:operatingsystems, :template_kind).where('operatingsystems.id' => opts[:operatingsystem_id], 'template_kinds.name' => opts[:kind])

    # once a template has been matched, we no longer look for others.

    if opts[:hostgroup_id] and opts[:environment_id]
      # try to find a full match to our host group and environment
      template ||= templates.joins(:template_combinations).where(
        "template_combinations.hostgroup_id" => opts[:hostgroup_id],
        "template_combinations.environment_id" => opts[:environment_id]).first
    end

    if opts[:hostgroup_id]
      # try to find a match with our hostgroup only
      template ||= templates.joins(:template_combinations).where(
        "template_combinations.hostgroup_id" => opts[:hostgroup_id],
        "template_combinations.environment_id" => nil).first
    end

    if opts[:environment_id]
      # search for a template based only on our environment
      template ||= templates.joins(:template_combinations).where(
        "template_combinations.hostgroup_id" => nil,
        "template_combinations.environment_id" => opts[:environment_id]).first
    end

    # fall back to the os default template
    template ||= templates.joins(:os_default_templates).where("os_default_templates.operatingsystem_id" => opts[:operatingsystem_id]).first
    template.is_a?(ConfigTemplate) ? template : nil
  end

  def self.build_pxe_default(renderer)
    if (proxies = SmartProxy.with_features("TFTP")).empty?
      error_msg = _("No TFTP proxies defined, can't continue")
    end

    if (default_template = ConfigTemplate.find_by_name("PXELinux global default")).nil?
      error_msg = _("Could not find a Configuration Template with the name \"PXELinux global default\", please create one.")
    end

    if error_msg.empty?
      begin
        @profiles = pxe_default_combos
        menu = renderer.render_safe(default_template.template, [:default_template_url], {:profiles => @profiles})
      rescue => e
        error_msg = _("failed to process template: %s" % e)
      end
    end

    return [422, error_msg] unless error_msg.empty?

    error_msgs = []
    proxies.each do |proxy|
      begin
        tftp = ProxyAPI::TFTP.new(:url => proxy.url)
        tftp.create_default({:menu => menu})

        @profiles.each do |combo|
          combo[:hostgroup].operatingsystem.pxe_files(combo[:hostgroup].medium, combo[:hostgroup].architecture).each do |bootfile_info|
            for prefix, path in bootfile_info do
              tftp.fetch_boot_file(:prefix => prefix.to_s, :path => path)
            end
          end
        end
      rescue => exc
        error_msgs << "#{proxy}: #{exc.message}"
      end
    end

    unless error_msgs.empty?
      msg = _("There was an error creating the PXE Default file: %s") % error_msgs.join(",")
      return [500, msg]
    end

    return [200, _("PXE Default file has been deployed to all Smart Proxies")]
  end

  def self.templates_for_os(os, major, minor)
    all.map { |template| template if template.supports?(os, major, minor) }.compact
  end

  def skip_strip_attrs
    ['template']
  end

  def locked?
    locked && !Foreman.in_rake?
  end

  def attrs
    return if template.blank?
    attrs = template.match(/\A<%#(.*?)[-]?%>/m)
    attrs.blank? ? nil : YAML.load(attrs[1])
  rescue SyntaxError
    nil
  end

  def supports?(os, major, minor)
    return unless os_hash.key? os

    if os_hash[os].blank?
      true # This template supports all versions of this OS
    elsif os_hash[os].key? major
      if os_hash[os][major].blank?
        true # We support all minors of this major
      elsif os_hash[os][major].include? minor
        true # We support this specific minor
      else
        false # We don't support this version
      end
    else
      false # No match found
    end
  end

  private

  def set_os_hash
    # Sets a hash like this: {"Debian"=>{"6"=>["0"], "7"=>["0"]}, "Ubuntu"=>{"10"=>["4"], "12"=>["4"]}}
    return unless attrs && attrs["oses"].is_a?(Array)

    self.os_hash = attrs["oses"].inject({}) do |hash, os|
      os = os.is_a?(String) ? os.split : []
      name = os[0]

      if os.length == 1
        # Provided an OS without version
        hash[name] = {}
      elsif os.length == 2
        # Provided an OS with a version
        (major, minor) = os[1].split('.').map { |number| number =~ /\A[-+]?[0-9]+\z/ ? number : nil}

        if major.blank?
          hash[name] = {}
        else
          if hash[name].nil?
            # First minor for this major
            hash[name] = {major => minor.nil? ? [] : [minor]}
          else
            # Additional minors for this major
            hash[name][major] = hash[name][major].nil? ? (minor.nil? ? [] : [minor]) : hash[name][major] + [minor]
          end
        end
      end
      hash
    end
  end

  def set_operating_systems
    return if self.snippet || os_hash.blank?

    oses = []

    os_hash.each do |os, versions|
      os_by_name = Operatingsystem.where(:name => os)
      if versions.empty?
        oses << os_by_name
      else
        versions.each do |major, minors|
          if minors.blank?
            oses << os_by_name.where(:major => major)
          else
            oses << os_by_name.where(:major => major, :minor => minors)
          end
        end
      end
    end

    self.operatingsystems << oses - self.operatingsystems
  end


  def check_if_template_is_locked
    errors.add(:base, _("This template is locked and may not be removed.")) if locked?
  end

  def template_changes
    actual_changes = changes

    # Changes to locked are special
    if locked == false && default
        owner = vendor ? vendor : "Foreman"
        errors.add(:base, _("This template is owned by %s and may not be unlocked.") % owner)
    end

    allowed_changes = %w(template_combinations template_associations locked)

    unless actual_changes.delete_if { |k, v| allowed_changes.include? k }.empty?
      errors.add(:base, _("This template is locked. Please clone it to a new template to customize."))
    end
  end

  # check if our template is a snippet, and remove its associations just in case they were selected.
  def check_for_snippet_associations
    return unless snippet
    self.hostgroups.clear
    self.environments.clear
    self.template_combinations.clear
    self.operatingsystems.clear
    self.template_kind = nil
  end

  def remove_trailing_chars
    self.template.gsub!("\r","") unless template.empty?
  end

  # get a list of all hostgroup, template combinations that a pxemenu will be
  # generated for
  def self.pxe_default_combos
    combos = []
    ConfigTemplate.joins(:template_kind).where("template_kinds.name" => "provision").includes(:template_combinations => [:environment, {:hostgroup => [ :operatingsystem, :architecture, :medium]}]).each do |template|
      template.template_combinations.each do |combination|
        hostgroup = combination.hostgroup
        if hostgroup and hostgroup.operatingsystem and hostgroup.architecture and hostgroup.medium
          combos << {:hostgroup => hostgroup, :template => template}
        end
      end
    end
    combos
  end
end
