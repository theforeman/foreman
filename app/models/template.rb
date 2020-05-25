class Template < ApplicationRecord
  include Exportable
  attr_accessor :modify_locked, :modify_default

  has_many :template_inputs, :dependent => :destroy, :foreign_key => 'template_id', :autosave => true

  accepts_nested_attributes_for :template_inputs, :allow_destroy => true

  validates_lengths_from_database

  validates :name, :presence => true
  validates :template, :presence => true
  validates :audit_comment, :length => {:maximum => 255}
  validate :template_changes, :if => :run_template_changes_validation?
  validate :inputs_unchanged_when_locked, :if => :run_template_changes_validation?
  validate do
    validate_unique_inputs!
  rescue Foreman::Exception => e
    errors.add :base, e.message
  end

  before_destroy :check_if_template_is_locked

  before_save :remove_trailing_chars

  attr_exportable :name, :description, :snippet, :template_inputs, :model => ->(template) { template.class.to_s }

  class Jail < Safemode::Jail
    allow :id, :name
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
    "<%#\n#{to_export(false).to_yaml.sub(/\A---$/, '').strip}\n-%>\n"
  end

  def to_erb
    metadata + template_without_metadata
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
    Foreman::Logging.logger('app').debug "setting attributes for #{name} with id: #{id || 'N/A'}"
    self.snippet = !!@importing_metadata[:snippet]
    self.default = options[:default] unless options[:default].nil?
    self.description = @importing_metadata[:description]
    self.locked = options[:locked] unless options[:locked].nil?
    handle_lock_on_import(options)

    import_taxonomies(options)
    import_custom_data(options)

    self
  end

  # Set template attributes
  #
  # based on +name it either finds existing template or builds a new one
  # then it applies changes to it and return this object, note no changes were saved at this point
  def self.import_without_save(name, text, options = {})
    template = find_without_collision :name, name
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
  #   :lock - lock imported templates (false by default), can be either boolean or lambda
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

  def acceptable_template_input_types
    self.class.acceptable_template_input_types
  end

  def self.acceptable_template_input_types
    TemplateInput::TYPES.keys
  end

  # override in subclass to handle taxonomy scope, see TaxonomyCollisionFinder
  def self.find_without_collision(attribute, name)
    find_or_initialize_by :name => name
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

  def render(host: nil, params: {}, variables: {}, mode: Foreman::Renderer::REAL_MODE, template_input_values: {}, source_klass: nil)
    source = Foreman::Renderer.get_source(template: self, host: host, klass: source_klass)
    scope = Foreman::Renderer.get_scope(host: host, params: params, variables: variables, mode: mode, template: self, source: source, template_input_values: template_input_values)
    Foreman::Renderer.render(source, scope)
  end

  def dup
    dup = super
    template_inputs.each do |input|
      dup.template_inputs.build input.attributes.except('template_id', 'id', 'created_at', 'updated_at')
    end
    dup
  end

  def validate_unique_inputs!
    duplicated_inputs = template_inputs.group_by(&:name).values.select { |values| values.size > 1 }.map(&:first)
    unless duplicated_inputs.empty?
      raise Foreman::Exception.new(N_('Duplicated inputs detected: %{duplicated_inputs}'), :duplicated_inputs => duplicated_inputs.map(&:name))
    end
  end

  def sync_inputs(inputs)
    inputs ||= []
    # Build a hash where keys are input names
    inputs = inputs.inject({}) { |h, input| h.update(input['name'] => input) }

    # Sync existing inputs
    template_inputs.each do |existing_input|
      if inputs.include?(existing_input.name)
        existing_input.assign_attributes(inputs.delete(existing_input.name))
      else
        existing_input.mark_for_destruction
      end
    end

    # Create new inputs
    inputs.each_value { |new_input| template_inputs.build(new_input) }
  end

  private

  # This method can be overridden in Template children classes to import additional attributes
  # specific to their type
  #
  # it can rely on self.template being updated and @importing_metadata to be populated with parsed
  # metadata
  def import_custom_data(_options)
    sync_inputs(@importing_metadata['template_inputs'])
  end

  # Sets operatingsystem_ids of a template, it's used by provisioning template and ptable, which
  # is why it lives here. Note that it's still considered as custom since other template types
  # don't have relation to operating systems.
  def import_oses(options)
    if @importing_metadata.key?('oses') && associate_metadata_on_import?(options)
      oses = Operatingsystem.authorized(:view_operatingsystems).all.select do |existing_os|
        @importing_metadata['oses'].any? { |imported_os| existing_os.to_label =~ /\A#{imported_os}/ }
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
      organization_ids << Organization.current.id if Organization.current && !organization_ids.include?(Organization.current.id)
    end
  end

  def import_locations(options)
    if @importing_metadata.key?('locations') && associate_metadata_on_import?(options)
      locations = User.current.my_locations.where(:title => @importing_metadata['locations'])
      self.location_ids = locations.map(&:id)
    else
      location_ids << Location.current.id if Location.current && !location_ids.include?(Location.current.id)
    end
  end

  def handle_lock_on_import(options)
    (self.locked = options[:lock].respond_to?(:call) ? options[:lock].call(self) : options[:lock]) unless options[:lock].nil?
  end

  def associate_metadata_on_import?(options)
    (options[:associate] == 'new' && new_record?) || (options[:associate] == 'always')
  end

  def allowed_changes
    @allowed_changes ||= %w(locked default)
  end

  def check_if_template_is_locked
    if locked?
      errors.add(:base, _("This template is locked and may not be removed."))
      throw(:abort)
    end
  end

  def template_changes
    actual_changes = changes

    # Locked & Default are Special
    if actual_changes.include?('locked') && !modify_locked
      if User.current.nil? || !User.current.can?("lock_#{self.class.to_s.underscore.pluralize}", self)
        errors.add(:base, _("You are not authorized to lock templates."))
      end
    end

    if actual_changes.include?('default') && !modify_default
      if User.current.nil? || !(User.current.can?(:create_organizations) || User.current.can?(:create_locations))
        errors.add(:base, _("You are not authorized to make a template default."))
      end
    end

    # API request can be changing the locked content (not allowed_changes) but the locked attribute at the same
    # time, so if changes include locked attribute (template is being locked or unlocked), we skip the lock error
    if !modify_locked && !actual_changes.delete_if { |k, v| allowed_changes.include? k }.empty? &&
        !changes.include?('locked')
      errors.add(:base, _("This template is locked. Please clone it to a new template to customize."))
    end
  end

  def remove_trailing_chars
    self.template = template.tr("\r", '') if template.present?
  end

  def run_template_changes_validation?
    (locked? || locked_changed?) && persisted? && !ForemanSeeder.is_seeding
  end

  def inputs_unchanged_when_locked
    inputs_changed = template_inputs.any? { |input| input.changed? || input.new_record? }
    if inputs_changed
      errors.add(:base, _('This template is locked. Please clone it to a new template to customize.'))
    end
  end
end

require_dependency 'provisioning_template'
require_dependency 'ptable'
