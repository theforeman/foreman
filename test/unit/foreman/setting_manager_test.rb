require 'test_helper'

class SettingPresenterTest < ActiveSupport::TestCase
  describe '#has_default?' do
    test 'returns false on empty array/string/hash' do
      ['', [], {}].each do |default_value|
        setting_presenter = Foreman::SettingPresenter.new(:settings_type => default_value.class.to_s.downcase, :name => 'foo', :default => default_value)
        assert !setting_presenter.has_default?
      end

      ['h', [''], {:one => 1}].each do |default_value|
        setting_presenter = Foreman::SettingPresenter.new(:settings_type => default_value.class.to_s.downcase, :name => 'foo', :default => default_value)
        assert setting_presenter.has_default?
      end
    end

    test 'returns true on setting_type boolean/integer' do
      [0, 1, -1].each do |default_value|
        setting_presenter = Foreman::SettingPresenter.new(:settings_type => default_value.class.to_s.downcase, :name => 'foo', :default => default_value)
        assert setting_presenter.has_default?
      end
      [false, true].each do |default_value|
        setting_presenter = Foreman::SettingPresenter.new(:settings_type => 'boolean', :name => 'foo', :default => default_value)
        assert setting_presenter.has_default?
      end
    end

    test 'for other settings_type' do
      ['', [], {}].each do |default_value|
        setting_presenter = Foreman::SettingPresenter.new(:settings_type => nil, :name => 'foo', :default => default_value)
        assert !setting_presenter.has_default?
      end

      ['h', [''], {:one => 1}].each do |default_value|
        setting_presenter = Foreman::SettingPresenter.new(:settings_type => 'somethingelse', :name => 'foo', :default => default_value)
        assert setting_presenter.has_default?
      end
    end
  end
end
