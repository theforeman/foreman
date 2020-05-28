module Foreman
  class SettingYamlType < ActiveModel::Type::Value
    def type
      :setting_yaml
    end

    def deserialize(value)
      value.nil? ? nil : YAML.load(value)
    end

    def serialize(value)
      value.to_yaml
    end
  end
  ActiveModel::Type.register(:setting_yaml, SettingYamlType)

  class SettingPresenter
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :category, :string, :default => 'Setting::General'
    attribute :name, :string
    attribute :description, :string
    attribute :default, :setting_yaml
    attribute :full_name, :string
    attribute :encrypted, :boolean, :default => false
    attribute :settings_type, :string
    attr_accessor :preset_value, :options

    def self.model_name
      Setting.model_name
    end

    def model_name
      Setting.model_name
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

    def value
      val = Setting.find_by(:name => name)&.value
      val = preset_value if val.nil?
      val = default if val.nil?
      val
    end

    def value=(val)
      record = Setting.find_by(:name => name)
      record ||= Setting.new(attributes)
      record.value = val
      record.save!
    end

    def readonly?
      SETTINGS.key?(name.to_sym)
    end

    def has_default?
      case settings_type
      when 'array', 'hash', 'string'
        !default.empty?
      when 'boolean', 'integer', 'falseclass', 'trueclass'
        true
      when 'nilclass'
        false
      else
        !default.nil?
      end
    end

    def has_collection?
      options.key?(:collection)
    end

    def translated_full_name
      full_name.nil? ? name : _(full_name)
    end

    def settings_type
      attribute(:settings_type) || Setting.setting_type_from_value(default)
    end

    def setting_attributes
      attributes.symbolize_keys.merge(default: default, value: preset_value)
    end
  end

  class SettingManager
    def self.ensure_classes_loaded!
      # in this phase, the classes are not fully loaded yet, load them
      Dir[
        File.join(Rails.root, "app/models/setting.rb"),
        File.join(Rails.root, "app/models/setting/*.rb"),
      ].each do |f|
        require_dependency(f)
      end
    end

    def categories
      Setting.descendants.map { |set_cls| set_cls.name }
    end

    attr_reader :settings

    def initialize
      @settings = {}
    end

    def ensure_setting_loaded
      return if Foreman.in_setup_db_rake?
      return true unless settings.empty?
      raise "Setting defaults has not been loaded yet, please ensure you run #load prior using it."
    end

    def cache_key(name)
      "settings/#{name}"
    end

    def clear_cache(name)
      # Rails cache returns false if the delete failed and nil if the key is missing
      if Rails.cache.delete(cache_key(name)) == false
        Rails.logger.warn "Failed to remove setting #{name} from cache"
      end
      true
    end

    def [](name)
      ensure_setting_loaded
      read_setting(name.to_s)
    end

    def []=(name, value)
      ensure_setting_loaded
      update_setting(name.to_s, value)
    end

    def settings_for(category)
      @settings.values.select { |_name, set| set[:category] == category }
    end

    def settings_by_categories
      res = ActiveSupport::OrderedHash.new
      res['Setting::General'] = nil
      res.merge(settings.values.group_by(&:category))
    end

    def load
      return unless Setting.table_exists?
      load_defaults
    end

    def add_default(category, name, default, description:, full_name: nil, value: nil, options: {})
      settings[name] = SettingPresenter.new({ :category => category,
                                              :name => name,
                                              :preset_value => value,
                                              :description => description,
                                              :default => default,
                                              :full_name => full_name,
                                              :encrypted => options.delete(:encrypted) || false,
                                              :settings_type => options.delete(:settings_type),
                                              :options => options })
    end

    def read_setting(name)
      Rails.cache.fetch(cache_key(name)) do
        settings[name]&.value
      end
    end

    def update_setting(name, value)
      setting = settings[name.to_s]
      setting.value = value
    end

    def load_defaults
      Setting.descendants.each(&:default_settings)
    end

    def setting_has_default?(name)
      settings[name].has_default?
    end
  end
end
