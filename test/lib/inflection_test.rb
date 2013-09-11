require 'test_helper'

class InflectionTest < ActiveSupport::TestCase

  test "puppetclass.singularize should equal puppetclass" do
    assert_equal "puppetclass", "puppetclass".singularize
  end

end