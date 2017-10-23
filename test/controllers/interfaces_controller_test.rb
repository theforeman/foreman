require 'test_helper'

class InterfacesControllerTest < ActionController::TestCase
  ['managed', 'bmc', 'bond', 'bridge'].each do |type|
    test "#new with #{type} interface attributes should render form" do
      nic = FactoryBot.build(:"nic_#{type}")
      xhr :get, :new, { :host => { :interfaces_attributes => { "0" => nic.attributes } } }, set_session_user
      assert_response :success
      assert_not_nil assigns(:interface)
      assert_template 'nic/new'
      assert_template "nic/#{type}s/_#{type}"
    end
  end
end
