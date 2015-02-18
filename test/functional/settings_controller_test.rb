require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  def test_index
    get :index, {}, set_session_user
    assert_template 'index'
  end

  def test_update_valid
    Setting::General.any_instance.stubs(:valid?).returns(true)
    new_value = 'root@another.com'
    put :update, {:id => settings(:attributes1).to_param, :setting => {:value => new_value}, :format => :json}, set_session_user
    assert :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert !response.empty?
    assert_equal new_value, response['setting']['value']
  end

  test "can render a new sti type setting" do
    class Setting::Valid < Setting; end
    assert Setting.create(:name => "foo", :default => "bar", :description => "test foo", :category => "Setting::Valid")
    get :index, {}, set_session_user
    assert_match /id='Valid'/, @response.body
  end

  test "does not render an old sti type setting" do
    assert Setting.create(:name => "foo", :default => "bar", :description => "test foo", :category => "Setting::Invalid")
    get :index, {}, set_session_user
    assert_no_match /id='Invalid'/, @response.body
  end

  test "invalid inline edit of string on integer field" do
    put :update, {:id => settings(:attributes16).to_param, :setting => {:value => '25aaaa'}, :format => :json}, set_session_user
    assert_equal 'Value is not a number', assigns(:setting).errors.full_messages.first
    assert :unprocessable_entity
  end
end
