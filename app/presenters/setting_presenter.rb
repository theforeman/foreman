class SettingPresenter
  include ActiveModel::Model
  include ActiveModel::Attributes

  include HiddenValue

  attribute :id, :integer
  attribute :category, :string, default: 'Setting::General'
  attribute :name, :string
  attribute :default
  attribute :value
  attribute :description, :string
  attribute :full_name, :string
  attribute :encrypted, :boolean, :default => false
  attribute :settings_type, :string
  attribute :config_file, :string
  attribute :updated_at

  def self.model_name
    Setting.model_name
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

  def settings_type
    attribute(:settings_type) || Setting.setting_type_from_value(default)
  end

  # ----- UI helpers ------

  def category_label
    category.constantize.humanized_category || _(category_name)
  end

  def category_name
    category.gsub(/Setting::/, '')
  end

  def select_values
    Setting.select_collection_registry.collection_for name
  end
end
