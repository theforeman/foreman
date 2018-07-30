class Template < ApplicationRecord
  include Exportable
  attr_accessor :modify_locked, :modify_default

  validates_lengths_from_database

  validates :name, :presence => true
  validates :template, :presence => true
  validates :audit_comment, :length => {:maximum => 255}
  validate :template_changes, :if => ->(template) { (template.locked? || template.locked_changed?) && template.persisted? && !Foreman.in_rake? }

  before_destroy :check_if_template_is_locked

  before_save :remove_trailing_chars

  attr_exportable :name, :snippet, :model => ->(template) { template.class.to_s }

  class Jail < Safemode::Jail
    allow :name
  end

  def skip_strip_attrs
    ['template']
  end

  def locked?
    locked && !Foreman.in_rake?
  end

  # if some child class needs to eager load some associations it can be added to this array
  def self.template_includes
    []
  end

  # May be extended or overwritten by plugins
  def self.preview_host_collection
    Host.authorized(:view_hosts).order(:name)
  end

  def metadata
    "<%#\n#{to_export(false).to_yaml.sub(/\A---$/, '').strip}\n%>\n"
  end

  def to_erb
    if self.template.start_with?('<%#')
      metadata + template_without_metadata
    else
      lines = template_without_metadata.split("\n")
      [ lines[0], metadata, lines[1..-1] ].flatten.join("\n")
    end
  end

  def template_without_metadata
    # Regexp like /.../m includes \n in .
    template.sub(/^<%#\n.*?name.*?%>$\n?/m, '')
  end

  def filename
    name.downcase.delete('-').gsub(/\s+/, '_') + '.erb'
  end

  def ignore_locking
    self.modify_locked = true
    yield
    self.modify_locked = false
    self
  end

  def ignore_default
    self.modify_default = true
    yield
    self.modify_default = false
    self
  end

  # Set attributes based on template +text and metadata found in this +text
  # the metadata parsing can be adjusted using +options
  def import_without_save(text, options = {})
    self.template = text
    @importing_metadata = self.class.parse_metadata(text)
    Foreman::Logging.logger('app').debug "setting attributes for #{self.name} with id: #{self.id || 'N/A'}"
    self.snippet = !!@importing_metadata[:snippet]
    self.locked = options[:lock] unless options[:lock].nil?
    self.default = options[:default] unless options[:default].nil?

    import_taxonomies(options)
    import_custom_data(options)

    self
  end

  # Set template attributes
  #
  # based on +name it either finds existing template or builds a new one
  # then it applies changes to it and return this object, note no changes were saved at this point
  def self.import_without_save(name, text, options = {})
    template = self.find_without_collision :name, name
    Foreman::Logging.logger('app').debug "#{template.new_record? ? 'building new' : 'updating existing'} template"
    template.import_without_save(text, options)
  end

  # Pull out the first erb comment only - /m is for a multiline regex
  def self.parse_metadata(text)
    extracted = text.match(/<%\#[\t a-z0-9=:]*(.+?).-?%>/m)
    extracted.nil? ? {} : YAML.safe_load(extracted[1]).with_indifferent_access
  rescue RuntimeError => e
    Foreman::Logging.exception('invalid metadata', e)
    {}
  end

  # Updates template metadata and save! it
  #
  # options can contain following keys
  #   :force - set to true if you want to bypass locked templates
  #   :associate - either 'new', 'always' or 'never', determines when the template should associate objects based on metadata
  #   :lock - lock imported templates (false by default)
  #   :default - default flag value (false by default)
  def self.import!(name, text, options = {})
    template = import_without_save(name, text, options)
    return template unless template.valid?
    if options[:force]
      template.ignore_locking { template.save! }
    else
      template.save!
    end
    template
  end

  # override in subclass to handle taxonomy scope, see TaxonomyCollisionFinder
  def self.find_without_collision(attribute, name)
    self.find_or_initialize_by :name => name
  end

  def self.default_render_scope_class
    nil
  end

  def default_render_scope_class
    self.class.default_render_scope_class
  end

  def self.log_render_results?
    true
  end

  def log_render_results?
    self.class.log_render_results?
  end

  def render(host: nil, params: {}, variables: {}, mode: Foreman::Renderer::REAL_MODE)
    source = Foreman::Renderer.get_source(template: self, host: host)
    scope = Foreman::Renderer.get_scope(host: host, params: params, variables: variables, mode: mode, template: self)
    Foreman::Renderer.render(source, scope)
  end

  private

  # This method can be overridden in Template children classes to import additional attributes
  # specific to their type
  #
  # it can rely on self.template being updated and @importing_metadata to be populated with parsed
  # metadata
  def import_custom_data(_options)
  end

  # Sets operatingsystem_ids of a template, it's used by provisioning template and ptable, which
  # is why it lives here. Note that it's still considered as custom since other template types
  # don't have relation to operating systems.
  def import_oses(options)
    if @importing_metadata.key?('oses') && associate_metadata_on_import?(options)
      oses = Operatingsystem.authorized(:view_operatingsystems).all.select do |existing_os|
        @importing_metadata['oses'].any? {|imported_os| existing_os.to_label =~ /\A#{imported_os}/}
      end
      self.operatingsystem_ids = oses.map(&:id)
    end
  end

  def import_taxonomies(options)
    process_taxonomies options, :organization
    process_taxonomies options, :location
  end

  def process_taxonomies(options, taxonomy)
    tax_options = options["#{taxonomy}_params".to_sym]
    if tax_options.empty?
      send("import_#{taxonomy.to_s.pluralize}", options)
    else
      self.attributes = tax_options
    end
  end

  def import_organizations(options)
    if @importing_metadata.key?('organizations') && associate_metadata_on_import?(options)
      organizations = User.current.my_organizations.where(:title => @importing_metadata['organizations'])
      self.organization_ids = organizations.map(&:id)
    else
      self.organization_ids << Organization.current.id if Organization.current && !self.organization_ids.include?(Organization.current.id)
    end
  end

  def import_locations(options)
    if @importing_metadata.key?('locations') && associate_metadata_on_import?(options)
      locations = User.current.my_locations.where(:title => @importing_metadata['locations'])
      self.location_ids = locations.map(&:id)
    else
      self.location_ids << Location.current.id if Location.current && !self.location_ids.include?(Location.current.id)
    end
  end

  def associate_metadata_on_import?(options)
    (options[:associate] == 'new' && self.new_record?) || (options[:associate] == 'always')
  end

  def allowed_changes
    @allowed_changes ||= %w(locked default)
  end

  def check_if_template_is_locked
    errors.add(:base, _("This template is locked and may not be removed.")) if locked?
  end

  def template_changes
    actual_changes = changes

    # Locked & Default are Special
    if actual_changes.include?('locked') && !self.modify_locked
      if User.current.nil? || !User.current.can?("lock_#{self.class.to_s.underscore.pluralize}", self)
        errors.add(:base, _("You are not authorized to lock templates."))
      end
    end

    if actual_changes.include?('default') && !self.modify_default
      if User.current.nil? || !(User.current.can?(:create_organizations) || User.current.can?(:create_locations))
        errors.add(:base, _("You are not authorized to make a template default."))
      end
    end

    # API request can be changing the locked content (not allowed_changes) but the locked attribute at the same
    # time, so if changes include locked attribute (template is being locked or unlocked), we skip the lock error
    if !self.modify_locked && !actual_changes.delete_if { |k, v| allowed_changes.include? k }.empty? &&
        !changes.include?('locked')
      errors.add(:base, _("This template is locked. Please clone it to a new template to customize."))
    end
  end

  def remove_trailing_chars
    self.template = template.tr("\r", '') if template.present?
  end
end

require_dependency 'provisioning_template'
require_dependency 'ptable'
