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
  def value=(*attr)
    @explicit_value = true
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
    if (res = query.match(/name\s*=\s*(\S+)/))
      name == ScopedSearch::QueryLanguage::Compiler.tokenize(query)[2]
    elsif (res = query.match(/description\s*~\s*(\S+)/))
      description.include? res[1]
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
    Setting.select_collection_registry.collection_for name
  end

  private

  # explicit value from mass assignment can not be nil
  def _assign_attribute(k, v)
    if k.to_s == 'value'
      @explicit_value = !v.nil?
      write_attribute(k, v)
    else
      super
    end
  end
end
