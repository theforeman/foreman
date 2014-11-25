require 'test_helper'

module MyPluginStrongParamsHelper
  include StrongParametersHelper

  def permitted_my_host_attributes
    permitted_attributes.host_attributes +
        [
          :interfaces_attributes => my_plugin_overriden_interface,
          :compute_attributes => my_plugin_vm_attributes,
          :lookup_values_attributes => [:lookup_key_id, :value, :_destroy, :id],
          :host_parameters_attributes => [:name, :value, :hidden_value, :_destroy, :nested, :id]
        ]
  end

  # Override the default vm_attributes method, and add my own parameters.
  def my_plugin_vm_attributes
    vm_attributes + [:machine_id, :server_location, :size]
  end

  def my_plugin_overriden_interface
    [:mac, :ip, :subnet, :fqdn]
  end
end

class MyHostsController < ::HostsController
include MyPluginStrongParamsHelper
ActionController::Parameters.action_on_unpermitted_parameters = :raise
  def create
    foreman_params
    head :ok
  end
end

class MyHostsControllerTest < ActionController::TestCase
  tests MyHostsController

  test 'valid added params will be cleared' do
    # Note that cpus are cleared on vm_attributes method, and therfore can be used.
    post :create, { :my_host => { :name => "para", :compute_attributes => {:machine_id => 1234, :server_location => "EU00", :size => "sm", :cpus => 2}}  }, set_session_user
    assert_response :ok
  end

  test 'valid overriden params will be cleared' do
    post :create, { :my_host => { :name => "para", :interfaces_attributes => {:mac => "aa:bb:cc:dd:ee:ff", :ip => "8.8.8.8", :subnet => "255.255.250.0", :fqdn => "plugin.noserver.foreman.org"}} }, set_session_user
    assert_response :ok
  end

end
