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
  attribute :select_values
  attribute :config_file
  attribute :updated_at, :datetime
  attribute :created_at, :datetime
  attr_accessor :options

  def self.from_setting(setting)
    SettingPresenter.new({id: setting.id,
                          name: setting.name,
                          category: setting.category,
                          description: setting.description,
                          settings_type: setting.settings_type,
                          default: setting.default,
                          full_name: setting.full_name,
                          updated_at: setting.updated_at,
                          created_at: setting.created_at,
                          config_file: setting.class.config_file,
                          select_values: setting.select_collection,
                          value: setting.value,
                          encrypted: setting.encrypted? })
  end

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
end
