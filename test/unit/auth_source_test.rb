require 'test_helper'

class AuthSourceTest < ActiveSupport::TestCase
  test "should not save without a name" do
    auth_source = AuthSource.new
    assert !auth_source.save
  end

  test "name should be unique" do
    auth_source = AuthSource.new :name => "connection"
    auth_source.save

    other_auth_source = AuthSource.new :name => "connection"
    assert !other_auth_source.save
  end

  test "name should not exceed 60 characters" do
    auth_source = AuthSource.new :name => "this_is_10this_is_20this_is_30this_is_40this_is_50this_is_60_"
    assert !auth_source.save
  end
end

