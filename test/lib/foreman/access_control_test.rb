require 'test_helper'
require 'foreman/access_control'

class AccessControlTest < ActiveSupport::TestCase
  test '#path_hash_to_string reads controller and action' do
    result = Foreman::AccessControl.path_hash_to_string({:controller => 'a', :action => 'b', :id => 'c'})
    assert_equal 'a/b', result
  end

  test '#normalize_path_hash converts namespaces to underscores for controller and trims the first slash' do
    assert_equal({ :controller => 'a_b' }, Foreman::AccessControl.normalize_path_hash({:controller => 'a::b'}))
    assert_equal({ :controller => 'a/b' }, Foreman::AccessControl.normalize_path_hash({:controller => 'a/b'}))
    assert_equal({ :controller => 'a/b' }, Foreman::AccessControl.normalize_path_hash({:controller => '/a/b'}))
  end
end
