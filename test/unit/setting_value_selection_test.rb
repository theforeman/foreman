require 'test_helper'

class SettingValueSelectionTest < ActiveSupport::TestCase
  test 'should create hash selection options' do
    hash = { :a => 'A', :b => 'B' }
    assert_equal hash, SettingValueSelection.new(hash, {}).collection
  end

  test 'should create array selection options' do
    array = [
      { :name => "Users", :class => 'user', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'login' },
      { :name => "Usergroups", :class => 'usergroup', :scope => 'visible', :value_method => 'id_and_type', :text_method => 'name' },
    ]
    blank_text = 'Select owner'

    res = SettingValueSelection.new(array, { :include_blank => blank_text }).collection
    assert_equal 3, res.size
    users = res.find { |item| item[:group_label] == 'Users' }
    usergroups = res.find { |item| item[:group_label] == 'Usergroups' }
    assert blank_text, res.first[nil]
    assert users
    assert usergroups
    assert_not_empty users[:children]
  end
end
