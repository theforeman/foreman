require 'test_helper'

class AuthSourceExternalTest < ActiveSupport::TestCase
  test 'aliases auth_method_name to to_label' do
    source = AuthSourceExternal.new
    assert_equal source.auth_method_name, source.to_label
  end
end
