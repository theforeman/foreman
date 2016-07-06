require 'test_helper'

class AuthSourceTest < ActiveSupport::TestCase
  def setup
    @auth_source = AuthSource.new
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should validate_length_of(:name).is_at_most(60)

  test "when auth_method_name is applied should return 'Abstract'" do
    @auth_source.name = "connection"
    @auth_source.save

    assert_equal "Abstract", @auth_source.auth_method_name
  end

# the self.authenticate method can't be tested yet, cause use the authenticate method which it isn't implemented yet

  test "should return search results if search free text is auth source name" do
    @auth_source.name = 'remote'
    @auth_source.save
    results = AuthSource.search_for('remote')
    assert_equal(1, results.count)
  end

  test "should return search results for name = auth source name" do
    @auth_source.name = 'my_ldap'
    @auth_source.save
    results = AuthSource.search_for('name = my_ldap')
    assert_equal(1, results.count)
    assert_equal 'my_ldap', results.first.name
  end
end
