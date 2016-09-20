require 'test_helper'

class AuthSourceTest < ActiveSupport::TestCase
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should validate_length_of(:name).is_at_most(60)

  test "when auth_method_name is applied should return 'Abstract'" do
    auth_source = AuthSource.new
    auth_source.name = "connection"
    auth_source.save
    assert_equal "Abstract", auth_source.auth_method_name
  end
end
