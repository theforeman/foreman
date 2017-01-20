class ProvisioningTemplate < Template
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  audited

  validates :name, :uniqueness => true
  validates :template_kind_id, :presence => true, :unless => Proc.new {|t| t.snippet }

  before_destroy EnsureNotUsedBy.new(:hostgroups, :environments, :os_default_templates)
  has_many :hostgroups, :through => :template_combinations
  has_many :environments, :through => :template_combinations
  has_many :template_combinations, :dependent => :destroy
  belongs_to :template_kind
  accepts_nested_attributes_for :template_combinations, :allow_destroy => true,
    :reject_if => ->(tc) { tc[:environment_id].blank? && tc[:hostgroup_id].blank? }
  has_and_belongs_to_many :operatingsystems, :join_table => :operatingsystems_provisioning_templates, :association_foreign_key => :operatingsystem_id, :foreign_key => :provisioning_template_id
  has_many :os_default_templates
  before_save :check_for_snippet_assoications

  # these can't be shared in parent class, scoped search can't handle STI properly
  # tested with scoped_search 3.2.0
  include Taxonomix
  scoped_search :on => :name,    :complete_value => true, :default_order => true
  scoped_search :on => :locked,  :complete_value => {:true => true, :false => false}
  scoped_search :on => :snippet, :complete_value => {:true => true, :false => false}
  scoped_search :on => :template

  scoped_search :relation => :operatingsystems, :on => :name, :rename => :operatingsystem, :complete_value => true
  scoped_search :relation => :environments,     :on => :name, :rename => :environment,     :complete_value => true
  scoped_search :relation => :hostgroups,       :on => :name, :rename => :hostgroup,       :complete_value => true
  scoped_search :relation => :template_kind,    :on => :name, :rename => :kind,            :complete_value => true

  attr_exportable :kind => Proc.new { |template| template.template_kind.try(:name) },
                  :oses => Proc.new { |template| template.operatingsystems.map(&:name).uniq }

  # Override method in Taxonomix as Template is not used attached to a Host,
  # and matching a Host does not prevent removing a template from its taxonomy.
  def used_taxonomy_ids(type)
    []
  end

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("#{Template.table_name}.name")
    end
  }

  scope :of_kind, ->(kind) { joins(:template_kind).where("template_kinds.name" => kind) }

  def self.template_ids_for(hosts)
    hosts = hosts.with_os.uniq
    oses = hosts.pluck(:operatingsystem_id)
    hostgroups = hosts.pluck(:hostgroup_id) | [nil]
    environments = hosts.pluck(:environment_id) | [nil]
    templates = ProvisioningTemplate.reorder(nil).joins(:operatingsystems, :template_kind).where('operatingsystems.id' => oses, 'template_kinds.name' => 'provision')
    ids = templates.joins(:template_combinations).where("template_combinations.hostgroup_id" => hostgroups, "template_combinations.environment_id" => environments).uniq.pluck(:id)
    ids += templates.joins(:os_default_templates).where("os_default_templates.operatingsystem_id" => oses).uniq.pluck(:id)
    ids.uniq
  end

  def self.template_includes
    super + [:template_kind, :template_combinations => [:hostgroup, :environment]]
  end

  def clone
    self.deep_clone(:include => [:operatingsystems, :organizations, :locations],
                    :except  => [:name, :locked, :default, :vendor])
  end

  def self.find_template(opts = {})
    raise ::Foreman::Exception.new(N_("Must provide template kind")) unless opts[:kind]
    raise ::Foreman::Exception.new(N_("Must provide an operating system")) unless opts[:operatingsystem_id]

    # first filter valid templates to our OS and requested template kind.
    templates = ProvisioningTemplate.joins(:operatingsystems, :template_kind).where('operatingsystems.id' => opts[:operatingsystem_id], 'template_kinds.name' => opts[:kind])

    # once a template has been matched, we no longer look for others.

    if opts[:hostgroup_id] && opts[:environment_id]
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
    template.is_a?(ProvisioningTemplate) ? template : nil
  end

  def self.find_global_default_template(name, kind)
    ProvisioningTemplate.unscoped.joins(:template_kind).where(:name => name, "template_kinds.name" => kind).first
  end

  def self.global_default_name(kind)
    "#{kind} global default"
  end

  def self.global_template_name_for(kind, renderer)
    global_setting = Setting.find_by(:name => "global_#{kind}")
    return global_setting.value if global_setting && global_setting.value.present?
    global_template_name = global_default_name(kind)
    renderer.logger.info "Could not find user defined global template from Settings for #{kind}, falling back to #{global_template_name}"
    global_template_name
  end

  def self.build_pxe_default(renderer)
    return [422, _("No TFTP proxies defined, can't continue")] if (proxies = SmartProxy.with_features("TFTP")).empty?
    error_msgs = []
    used_templates = []
    TemplateKind::PXE.each do |kind|
      global_template_name = global_template_name_for(kind, renderer)
      if (default_template = find_global_default_template global_template_name, kind).nil?
        error_msg = _("Could not find a Configuration Template with the name \"%s\", please create one.") % global_template_name
      else
        begin
          @profiles = pxe_default_combos
          allowed_helpers = Foreman::Renderer::ALLOWED_GENERIC_HELPERS + [ :default_template_url ]
          menu = renderer.render_safe(default_template.template, allowed_helpers, :profiles => @profiles)
        rescue => exception
          Foreman::Logging.exception("Cannot render '#{global_template_name}'", exception)
          error_msgs << "#{exception.message} (#{kind})"
        end
        return [422, error_msg] unless error_msg.empty?
        proxies.each do |proxy|
          begin
            tftp = ProxyAPI::TFTP.new(:url => proxy.url)
            tftp.create_default(kind, {:menu => menu})
            fetch_boot_files_combo(tftp)
          rescue => exception
            Foreman::Logging.exception("Cannot deploy rendered template '#{global_template_name}' to '#{proxy}'", exception)
            error_msgs << "#{proxy}: #{exception.message} (#{kind})"
          end
        end
      end
      used_templates << global_template_name
    end

    if error_msgs.empty?
      [200, _("PXE files for templates %s have been deployed to all Smart Proxies") % used_templates.to_sentence]
    else
      [500, _("There was an error creating the PXE file: %s") % error_msgs.join(", ")]
    end
  end

  def self.fetch_boot_files_combo(tftp)
    @profiles.each do |combo|
      combo[:hostgroup].operatingsystem.pxe_files(combo[:hostgroup].medium, combo[:hostgroup].architecture).each do |bootfile_info|
        for prefix, path in bootfile_info do
          tftp.fetch_boot_file(:prefix => prefix.to_s, :path => path)
        end
      end
    end
  end

  def self.preview_host_collection
    super.where(:managed => true)
  end

  # get a list of all hostgroup, template combinations that a pxemenu will be
  # generated for
  def self.pxe_default_combos
    combos = []
    ProvisioningTemplate.joins(:template_kind).where("template_kinds.name" => "provision").includes(:template_combinations => [:environment, {:hostgroup => [ :operatingsystem, :architecture, :medium]}]).each do |template|
      template.template_combinations.each do |combination|
        hostgroup = combination.hostgroup
        if hostgroup && hostgroup.operatingsystem && hostgroup.architecture && hostgroup.medium
          combos << {
            :hostgroup => hostgroup,
            :template => template,
            :kernel => hostgroup.operatingsystem.kernel(hostgroup.architecture),
            :initrd => hostgroup.operatingsystem.initrd(hostgroup.architecture),
            :pxe_type => hostgroup.operatingsystem.pxe_type
          }
        end
      end
    end
    combos.sort_by! { |profile| [profile[:hostgroup].title, profile[:template]] }
  end

  def global_default?
    return unless template_kind
    setting = Setting.find_by :name => "global_#{template_kind.name}"
    return unless setting
    setting.value == name
  end

  private

  def allowed_changes
    super + %w(template_combinations template_associations)
  end

  # check if our template is a snippet, and remove its associations just in case they were selected.
  def check_for_snippet_assoications
    return unless snippet
    self.hostgroups.clear
    self.environments.clear
    self.template_combinations.clear
    self.operatingsystems.clear
    self.template_kind = nil
  end
end
