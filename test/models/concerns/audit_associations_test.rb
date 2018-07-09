require 'test_helper'

class AuditAssociationsTest < ActiveSupport::TestCase
  setup do
    @user = FactoryBot.build(:user)
  end

  let (:role) { FactoryBot.create(:role) }

  test "Should audit associations on creation" do
    @user.role_ids = [role.id]
    @user.save!

    audit = @user.audits.last
    assert_equal [role.id], audit.audited_changes['role_ids']
    assert_equal 'create', audit.action
  end

  test "Should audit associations on update" do
    @user.save!
    assert_empty @user.audits.last.audited_changes['role_ids']

    @user.role_ids = [role.id]
    @user.save!

    audit = @user.audits.last
    assert_equal [[], [role.id]], audit.audited_changes['role_ids']
    assert_equal 'update', audit.action
  end

  test "Should audit associations on destruction" do
    @user.role_ids = [role.id]
    @user.save!
    assert_equal [role.id], @user.audits.last.audited_changes['role_ids']

    @user.destroy!

    audit = @user.audits.last
    # The default role is added in after_save to the user
    assert_equal [Role.default.id, role.id].sort, audit.audited_changes['role_ids'].sort
    assert_equal 'destroy', audit.action
  end
end
