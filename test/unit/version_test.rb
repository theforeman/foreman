require 'test_helper'

class VersionTest < ActiveSupport::TestCase
  test "given version 1.2.3" do
    v = Foreman::Version.new "1.2.3"
    assert_equal "1", v.major
    assert_equal "2", v.minor
    assert_equal "3", v.build
    assert_equal "1.2", v.short
    assert_equal "", v.tag
    assert_equal "1.2.3", v.full
    assert_equal "1.2.3", v.notag
  end

  test "given version 1.0-develop" do
    v = Foreman::Version.new "1.0-develop"
    assert_equal "1", v.major
    assert_equal "0", v.minor
    assert v.build.nil?
    assert_equal "1.0", v.short
    assert_equal "develop", v.tag
    assert_equal "1.0", v.notag
  end

  test "given version 1.3.0 RC5" do
    v = Foreman::Version.new "1.3.0-RC5"
    assert_equal "1", v.major
    assert_equal "3", v.minor
    assert_equal "0", v.build
    assert_equal "1.3", v.short
    assert_equal "RC5", v.tag
    assert_equal "1.3.0", v.notag
  end
end
