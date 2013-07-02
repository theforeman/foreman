# redMine - project management software
# Copyright (C) 2006-2008  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require "test_helper"

class RoleTest < ActiveSupport::TestCase

  it "should respond_to user_roles" do
    role = roles(:manager)
    role.must_respond_to :user_roles
    role.must_respond_to :users
  end

  it "should have unique name" do
    # Manager is in role fixtures
    Role.new(:name => "Manager").wont_be :valid?
    role = Role.new(:name => "Supervisor")
    role.must_be :valid?
  end

  it "should not be valid without a name" do
    role = Role.new(:name => "")
    role.wont_be :valid?
  end

  it "should ensure length of name is at most 30" do
    thirty = 'abcdefghijklmnopqrstuvwxyz1234'
    thirtyone = 'abcdefghijklmnopqrstuvwxyz12345'
    role = Role.new(:name => thirty)
    role.must_be :valid?
    role = Role.new(:name => thirtyone)
    role.wont_be :valid?
  end

  it "should allow value 'a role name' for name" do
    role = Role.new(:name => "a role name")
    role.must_be :valid?
  end

  it "should not allow semi colon in name" do
    role = Role.new(:name => ";a role name")
    role.wont_be :valid?
  end

  it "should not allow a leading space on name" do
    role = Role.new(:name => " a role name")
    role.wont_be :valid?
  end

  it "should not allow a trailing space on name" do
    role = Role.new(:name => "a role name ")
    role.wont_be :valid?
  end

  def test_add_permission
    role = Role.find(1)
    size = role.permissions.size
    role.add_permission!("apermission", "anotherpermission")
    role.reload
    assert role.permissions.include?(:anotherpermission)
    assert_equal size + 2, role.permissions.size
  end

  def test_remove_permission
    role = Role.find(1)
    size = role.permissions.size
    perm = role.permissions[0..1]
    role.remove_permission!(*perm)
    role.reload
    assert ! role.permissions.include?(perm[0])
    assert_equal size - 2, role.permissions.size
  end

  context "System roles" do
    should "return the anonymous role" do
      role = Role.anonymous
      assert role.builtin?
      assert_equal Role::BUILTIN_ANONYMOUS, role.builtin
    end

    context "with a missing anonymous role" do
      setup do
        Role.delete_all("builtin = #{Role::BUILTIN_ANONYMOUS}")
      end

      should "create a new anonymous role" do
        assert_difference('Role.count') do
          Role.anonymous
        end
      end

      should "return the anonymous role" do
        role = Role.anonymous
        assert role.builtin?
        assert_equal Role::BUILTIN_ANONYMOUS, role.builtin
      end
    end
  end

  context "Default_user" do
    should "return the default_user role" do
      role = Role.default_user
      assert role.builtin?
      assert_equal Role::BUILTIN_DEFAULT_USER, role.builtin
    end

    context "with a missing default_user role" do
      setup do
        Role.delete_all("builtin = #{Role::BUILTIN_DEFAULT_USER}")
      end

      should "create a new default_user role" do
        assert_difference('Role.count') do
          Role.default_user
        end
      end

      should "return the default_user role" do
        role = Role.default_user
        assert role.builtin?
        assert_equal Role::BUILTIN_DEFAULT_USER, role.builtin
      end
    end
  end

  describe ".for_current_user" do
    context "there are two roles, one of them is assigned to current user" do
      let(:first) { Role.create(:name => 'First') }
      let(:second) { Role.create(:name => 'Second') }
      before do
        User.current = users(:one)
        User.current.roles<< first
      end

      subject { Role.for_current_user.all }
      it { subject.must_include(first) }
      it { subject.wont_include(second) }
    end

  end
end
