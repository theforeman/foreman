# encoding: utf-8
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

  it "should allow value 'a role name' for name" do
    role = Role.new(:name => "a role name")
    role.must_be :valid?
  end

  it "should allow utf characters in name" do
    role = Role.new(:name => "トメル３４；。")
    role.must_be :valid?
  end

  it "should allow email address in name" do
    role = Role.new(:name => "test@example.com")
    role.must_be :valid?
  end

  it "should strip leading space on name" do
    role = Role.new(:name => " a role name")
    role.must_be :valid?
  end

  it "should strip a trailing space on name" do
    role = Role.new(:name => "a role name ")
    role.must_be :valid?
  end

  context "System roles" do
    should "return the anonymous role" do
      role = Role.anonymous
      assert role.builtin?
      assert_equal Role::BUILTIN_ANONYMOUS, role.builtin
    end

    context "with a missing anonymous role" do
      setup do
        role_ids = Role.where("builtin = #{Role::BUILTIN_ANONYMOUS}").pluck(:id)
        UserRole.where(:role_id => role_ids).destroy_all
        Filter.where(:role_id => role_ids).destroy_all
        Role.where(:id => role_ids).delete_all
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
        role_ids = Role.where("builtin = #{Role::BUILTIN_DEFAULT_USER}").pluck(:id)
        UserRole.where(:role_id => role_ids).destroy_all
        Filter.where(:role_id => role_ids).destroy_all
        Role.where(:id => role_ids).delete_all
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

      subject { Role.for_current_user.to_a }
      it { subject.must_include(first) }
      it { subject.wont_include(second) }
    end
  end

  describe "#add_permissions" do
    setup do
      @permission1 = FactoryGirl.create(:permission, :name => 'permission1')
      @permission2 = FactoryGirl.create(:permission, :architecture, :name => 'permission2')
      @role = FactoryGirl.build(:role, :permissions => [])
    end

    it "should build filters with assigned permission" do
      @role.add_permissions [@permission1.name, @permission2.name.to_sym]
      assert @role.filters.all?(&:unlimited?)

      permissions = @role.filters.map { |f| f.filterings.map(&:permission) }.flatten
      assert_equal 2, @role.filters.size
      assert_includes permissions, Permission.find_by_name(@permission1.name)
      assert_includes permissions, Permission.find_by_name(@permission2.name)
      # not saved yet
      assert_empty @role.permissions
    end

    it "should raise error when given permission does not exist" do
      assert_raises ArgumentError do
        @role.add_permissions ['does_not_exist']
      end
    end

    it "accespts one permissions instead of array as well" do
      @role.add_permissions @permission1.name
      permissions = @role.filters.map { |f| f.filterings.map(&:permission) }.flatten

      assert_equal 1, @role.filters.size
      assert_includes permissions, Permission.find_by_name(@permission1.name)
    end

    it "sets search filter to all filters" do
      search = "id = 1"
      @role.add_permissions [@permission1.name, @permission2.name.to_sym], :search => search
      refute @role.filters.any?(&:unlimited?)
      assert @role.filters.all? { |f| f.search == search }
    end
  end

  describe "#add_permissions!" do
    setup do
      @permission1 = FactoryGirl.create(:permission, :name => 'permission1')
      @permission2 = FactoryGirl.create(:permission, :architecture, :name => 'permission2')
      @role = FactoryGirl.build(:role, :permissions => [])
    end

    it "persists built permissions" do
      assert @role.add_permissions!([@permission1.name, @permission2.name.to_sym])
      @role.reload

      permissions = @role.permissions
      assert_equal 2, @role.filters.size
      assert_includes permissions, Permission.find_by_name(@permission1.name)
      assert_includes permissions, Permission.find_by_name(@permission2.name)
    end
  end
end
