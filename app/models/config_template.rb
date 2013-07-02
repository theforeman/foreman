class ConfigTemplate < ActiveRecord::Base
  include Authorization
  include Taxonomix
  audited :allow_mass_assignment => true
  self.auditing_enabled = !(File.basename($0) == "rake" && ARGV.include?("db:migrate"))
  attr_accessible :name, :template, :template_kind_id, :snippet, :template_combinations_attributes, :operatingsystem_ids, :audit_comment
  validates_presence_of :name, :template
  validates_presence_of :template_kind_id, :unless => Proc.new {|t| t.snippet }
  validates_uniqueness_of :name
  before_destroy EnsureNotUsedBy.new(:hostgroups, :environments, :os_default_templates)
  has_many :hostgroups, :through => :template_combinations
  has_many :environments, :through => :template_combinations
  has_many :template_combinations, :dependent => :destroy
  belongs_to :template_kind
  accepts_nested_attributes_for :template_combinations, :allow_destroy => true, :reject_if => lambda {|tc| tc[:environment_id].blank? and tc[:hostgroup_id].blank? }
  has_and_belongs_to_many :operatingsystems
  has_many :os_default_templates
  before_save :check_for_snippet_assoications, :remove_trailing_chars
  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("config_templates.name")
    end
  }

  scoped_search :on => :name,    :complete_value => true, :default_order => true
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
      template = templates.joins(:hostgroups, :environments).where("hostgroups.id" => opts[:hostgroup_id], "environments.id" => opts[:environment_id]).first
    end

    if opts[:hostgroup_id]
      # try to find a match with our hostgroup only
      template ||= templates.joins(:hostgroups).where("hostgroups.id" => opts[:hostgroup_id]).first
    end

    if opts[:environment_id]
      # search for a template based only on our environment
      template ||= templates.joins(:environments).where("environments.id" => opts[:environment_id]).first
    end

    # fall back to the os default template
    template ||= templates.joins(:os_default_templates).where("os_default_templates.operatingsystem_id" => opts[:operatingsystem_id]).first
    template.is_a?(ConfigTemplate) ? template : nil
  end

  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?

    return true if User.current and User.current.allowed_to?("#{operation}_templates".to_sym)

    errors.add :base, (_("You do not have permission to %s this template") % operation)
    false
  end

  def as_json(options={})
    options ||= {}
    super({:only => [:name, :template, :id, :snippet],:include => [:template_kind]}.merge(options))
  end

  def self.build_pxe_default(renderer)
    if (proxies = SmartProxy.tftp_proxies).empty?
      error_msg = _("No TFTP proxies defined, can't continue")
    end

    if (default_template = ConfigTemplate.find_by_name("PXE Default File")).nil?
      error_msg = _("Could not find a Configuration Template with the name \"PXE Default File\", please create one.")
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

  private

  # check if our template is a snippet, and remove its associations just in case they were selected.
  def check_for_snippet_assoications
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
