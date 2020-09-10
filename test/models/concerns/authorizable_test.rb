require 'test_helper'

class AuthorizableTest < ActiveSupport::TestCase
  def setup
    User.current = users :admin
    user_role = FactoryBot.create(:user_user_role)
    @user = user_role.owner
    role = user_role.role
    permission = Permission.find_by_name('create_domains')
    role.filters << FactoryBot.create(:filter, :on_name_starting_with_a, :role => role, :permissions => [permission])
  end

  test "create permissions respects search conditions of filters" do
    as_user @user do
      valid = FactoryBot.build(:domain, :name => 'a.domain.will.save')
      assert valid.save

      invalid = FactoryBot.build(:domain, :name => 'b.domain.wont.save')
      refute invalid.save
      assert_equal 1, invalid.errors.messages.size
      assert_include invalid.errors.messages.keys, :base
    end
  end

  test "rollback orchestration" do
    Domain.stub(:included_modules, [Orchestration]) do
      as_user @user do
        invalid = FactoryBot.build(:domain, :name => 'b.domain.wont.save')
        invalid.stubs(:queue).returns([])
        invalid.expects(:fail_queue).once
        refute invalid.save
      end
    end
  end

  test "#permission_name" do
    domain = FactoryBot.build_stubbed(:domain)
    assert_equal 'create_domains', domain.permission_name('create')
    assert_nil domain.permission_name('does_not_exist')
  end
end
