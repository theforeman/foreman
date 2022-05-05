class SettingPresenter
  include ActiveModel::Model
  include ActiveModel::Attributes

  include HiddenValue

  attribute :category, :string, default: 'Setting'
  attribute :context
  attribute :name, :string
  attribute :default
  attribute :value
  attribute :description, :string
  attribute :full_name, :string
  attribute :encrypted, :boolean, :default => false
  attribute :settings_type, :string
  attribute :config_file, :string
  attribute :updated_at

  attr_accessor :collection

  def self.graphql_type
    '::Types::Setting'
  end

  def self.model_name
    Setting.model_name
  end

  # Value set through setter can be explicit nil
  def value_from_db=(value)
    @explicit_value = true
    self.value = value
  end

  # Mass assigned value is not relevant if it is a nil
  def value=(value)
    @explicit_value = !value.nil?
    super
  end

  def explicit_value?
    @explicit_value
  end

  def model_name
    self.class.model_name
  end

  def to_model
    self
  end

  def id
    name
  end

  def persisted?
    true
  end

  def encrypted?
    !!encrypted
  end

  def hidden_value?
    encrypted?
  end

  def readonly?
    SETTINGS.key?(name.to_sym)
  end

  def value
    SETTINGS.fetch(name.to_sym) { explicit_value? ? super : default }
  end

  def settings_type
    attribute(:settings_type) || Setting.setting_type_from_value(default)
  end

  def matches_search_query?(query)
    tokenized = ScopedSearch::QueryLanguage::Compiler.tokenize(query)

    if tokenized.include?(:and) || tokenized.include?(:or)
      raise ::Foreman::Exception.new N_('Unsupported search operators :and / :or')
    end

    if query =~ /name\s*=\s*(\S+)/
      name == tokenized.last
    elsif query =~ /name\s*~\s*(\S+)/
      search_value = tokenized.last
      name.include?(search_value) || full_name&.include?(search_value)
    elsif query =~ /description\s*~\s*(\S+)/
      search_value = tokenized.last
      description.include? search_value
    else
      description.include?(query) || name.include?(query) || full_name&.include?(query)
    end
  end

  # ----- UI helpers ------

  def category_label
    Foreman::SettingManager.categories[category] || category.safe_constantize&.humanized_category || category_name
  end

  def category_name
    category.delete_prefix('Setting::')
  end

  def select_values
    Foreman.settings.select_collection_registry.collection_for name
  end
end
