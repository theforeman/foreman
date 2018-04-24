require 'test_helper'

class AuditAssociationsTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.build(:user)
  end

  let (:role) { FactoryBot.create(:role) }

  test "find_association_class should be give a class_name" do
    role_class = @user.send('find_association_class', 'roles')
    assert_equal Role, role_class
  end

  test "Should audit associations on creation" do
    @user.role_ids = [role.id]
    @user.save!

    audit = @user.audits.last
    assert_equal role.to_label, audit.audited_changes['roles']
    assert_equal 'create', audit.action
  end

  test "Should audit associations on update" do
    @user.save!
    assert_empty @user.audits.last.audited_changes['roles']

    @user.role_ids = [role.id]
    @user.save!

    audit = @user.audits.last
    assert_equal ["", role.to_label], audit.audited_changes['roles']
    assert_equal 'update', audit.action
  end

  test "Should audit associations on destruction" do
    @user.role_ids = [role.id]
    @user.save!
    assert_equal role.to_label, @user.audits.last.audited_changes['roles']

    @user.destroy!

    audit = @user.audits.last
    # The default role is added in after_save to the user
    assert_equal [Role.default.to_label, role.to_label].sort.join(', '), audit.audited_changes['roles']
    assert_equal 'destroy', audit.action
  end
end
