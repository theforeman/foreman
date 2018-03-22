require 'test_helper'

class AssociationAuthorizerTest < ActiveSupport::TestCase
  def setup
    @hostgroup = FactoryBot.create(:hostgroup, :with_domain, :with_os)
    @host = FactoryBot.create(:host, :managed, :hostgroup => @hostgroup)
    @user = FactoryBot.create(:user)
  end

  test "user with permissions can view host" do
    role = FactoryBot.build(:role, :name => 'can_view_host')
    role.add_permissions!(['view_hosts'])
    @user.update_attribute :roles, [role]

    as_user @user do
      authorized = AssociationAuthorizer.authorized_associations(Hostgroup.reflect_on_association(:hosts).klass, :hosts)
      assert authorized.include?(@host)
    end
  end

  test "user without permissions can't view host" do
    as_user @user do
      authorized = AssociationAuthorizer.authorized_associations(Hostgroup.reflect_on_association(:hosts).klass, :hosts)
      refute authorized.include?(@host)
    end
  end

  test "authorized_associations should raise unknown permission exception when should_raise_exception is true" do
    assert_raise(Foreman::Exception) do
      AssociationAuthorizer.permission_name('non_existing_permission', 'view', true)
    end
  end

  test "authorized_associations should return false for unknown permission when should_raise_exception is false" do
    permission = AssociationAuthorizer.permission_name('non_existing_permission', 'view', false)
    assert_equal false, permission
  end

  test "authorized_associations should return permission if it exists" do
    permission = AssociationAuthorizer.permission_name(:host, 'view', false)
    assert_equal "view_hosts", permission
  end

  test "authorized_associations should use overridden permission name if class has one" do
    FactoryBot.create(:permission, :name => 'view_buildings')

    class House
      def self.permission_name
        'buildings'
      end
    end

    permission = AssociationAuthorizer.permission_name(House, 'view', false)
    assert_equal 'view_buildings', permission
  end
end
