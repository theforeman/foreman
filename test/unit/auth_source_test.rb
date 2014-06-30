require 'test_helper'

class AuthSourceTest < ActiveSupport::TestCase
  def setup
    @auth_source = AuthSource.new
  end

  test "should not save without a name" do
    assert !@auth_source.save
  end

  test "name should be unique" do
    @auth_source.name = "connection"
    @auth_source.save

    other_auth_source = AuthSource.create :name => "connection"
    assert !other_auth_source.save
  end

  test "name should not exceed 60 characters" do
    @auth_source.name = "a" * 61
    assert !@auth_source.save
  end

  test "when auth_method_name is applied should return 'Abstract'" do
    @auth_source.name = "connection"
    @auth_source.save

    assert_equal "Abstract", @auth_source.auth_method_name
  end

# the self.authenticate method can't be tested yet, cause use the authenticate method which it isn't implemented yet

  test "type cannot be changed by mass-assignment" do
    assert_raise ActiveModel::MassAssignmentSecurity::Error do
      @auth_source.update_attributes(:type => AuthSourceHidden.name)
    end
  end
end

