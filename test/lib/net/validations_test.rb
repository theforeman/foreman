require 'test_helper'
require 'net'

class ValidationsTest < ActiveSupport::TestCase
  include Net::Validations

  test "mac address should be valid" do
    assert_nothing_raised Net::Validations::Error do
      validate_mac "aa:bb:cc:dd:ee:ff"
    end
  end

  test "mac should be invalid" do
    assert_raise Net::Validations::Error do
      validate_mac "abc123asdas"
    end
  end

end
