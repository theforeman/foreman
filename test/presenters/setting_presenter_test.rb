require 'test_helper'

class SettingPresenterTest < ActiveSupport::TestCase
  def test_should_hide_value_if_encrypted
    setting = Setting.create(name: 'encrypted', value: 'clear', encrypted: true)
    presenter = SettingPresenter.from_setting(setting)
    assert_equal '*****', presenter.safe_value
  end
end
