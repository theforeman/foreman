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
  should have_many(:user_roles)
  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should allow_value('a role name').for(:name)
  should allow_value('トメル３４；。').for(:name)
  should allow_value('test@example.com').for(:name)

  it "should strip leading space on name" do
    role = Role.new(:name => " a role name")
    role.must_be :valid?
  end

  it "should strip a trailing space on name" do
    role = Role.new(:name => "a role name ")
    role.must_be :valid?
  end

  it "should delete role who has users" do
    role = Role.create(:name => 'First')
    user = FactoryGirl.create(:user)
    role.users = [user]
    assert_difference('Role.count', -1) do
      role.destroy
    end
  end

  it "should not rename locked role" do
    manager = Role.find_by :name => "Manager"
    manager.name = "Renamed Manager"
    refute manager.save
    assert_equal "This role is locked from being modified by users.", manager.errors.messages[:base].first
  end

  it "should rename locked role when required" do
    manager = Role.find_by :name => "Manager"
    manager.name = "Renamed Manager"
    manager.modify_locked = true
    assert manager.save
  end

  it "should not modify locked role permissions" do
    viewer = Role.find_by :name => "Viewer"
    viewer.add_permissions [:create_hosts]
    refute viewer.valid?
    assert_equal "is locked for user modifications.", viewer.errors.messages.values.first.first
  end

  it "should modify locked role permissions when required" do
    viewer = Role.find_by :name => "Viewer"
    viewer.modify_locked = true
    viewer.add_permissions [:create_hosts]
    assert viewer.valid?
  end

  it "should modify role using ignore_locking method" do
    viewer = Role.find_by :name => "Viewer"
    viewer.ignore_locking do |role|
      role.name = "Changed Viewer"
      role.save!
    end
    assert Role.find_by(:name => "Changed Viewer")
    refute Role.find_by(:name => "Viewer")
  end

  it "should be givable even when locked" do
    user = FactoryGirl.create(:user)
    role = roles(:manager)
    assert role.locked?
    user.roles << role
    assert user.save
  end

  describe "Cloning" do
    let(:role) { FactoryGirl.create(:role) }
    let(:cloned_role) do
      cloned_role = role.clone
      cloned_role.name = "Clone of #{role.name}"
      cloned_role.save!
      cloned_role
    end

    it "cloned role keeps link to origin" do
      assert_equal role, cloned_role.cloned_from
    end

    it "allows me to find all roles that were cloned from origin" do
      another_role = FactoryGirl.create(:role)
      cloned_role # enforce lazy let to create the cloned role and role
      clones = role.cloned_roles
      assert_include clones, cloned_role
      assert_not_include clones, another_role
    end

    it 'nullifies the relation when origin is deleted' do
      cloned_role # enforce lazy let to create the cloned role and role
      assert role.destroy
      cloned_role.reload
      assert_nil cloned_role.cloned_from
    end

    it 'can be found by cloned scope' do
      cloned_role # enforce lazy let to create the cloned role and role
      assert_include Role.cloned, cloned_role
      assert_not_include Role.cloned, role
    end
  end

  context "System roles" do
    should "return the default role" do
      role = Role.default
      assert role.builtin?
      assert_equal Role::BUILTIN_DEFAULT_ROLE, role.builtin
    end

    context "with a missing default role" do
      setup do
        role_ids = Role.where("builtin = #{Role::BUILTIN_DEFAULT_ROLE}").pluck(:id)
        UserRole.where(:role_id => role_ids).destroy_all
        roles = Role.where(:id => role_ids)
        roles.each do |found_role|
          found_role.ignore_locking do |r|
            r.filters.destroy_all
            r.delete
          end
        end
      end

      should "create a new default role" do
        assert_difference('Role.count') do
          Role.default
        end
      end

      should "return the default role" do
        role = Role.default
        assert role.builtin?
        assert_equal Role::BUILTIN_DEFAULT_ROLE, role.builtin
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

    context "when current user is admin for_current_user should return all roles" do
      setup do
        User.current = users(:admin)
      end

      test "Admin user should query Role model with no restrictions" do
        Role.expects(:where).with('0 = 0')
        Role.for_current_user
      end
    end
  end

  describe ".permissions=" do
    let(:role) { FactoryGirl.build(:role) }

    it 'accepts not unique list of permissions' do
      role.expects(:add_permissions).once.with(['a','b'])
      role.permissions = [
        FactoryGirl.build(:permission, :name => 'a'),
        FactoryGirl.build(:permission, :name => 'b'),
        FactoryGirl.build(:permission, :name => 'a'),
        FactoryGirl.build(:permission, :name => 'b')
      ]
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

    it "should add permission to an existing filter" do
      role = roles(:destroy_hosts)
      assert_equal 1, role.permissions.count
      role.add_permissions!([:create_hosts])
      assert_equal 2, role.permissions.count
      assert_equal 1, role.filters.count
    end

    it "should add permissions to a newly created filter" do
      role = roles(:destroy_hosts)
      assert_equal 1, role.permissions.count
      role.add_permissions!([:create_architectures])
      assert_equal 2, role.permissions.count
      assert_equal 2, role.filters.count
    end
  end

  context 'having role with filters' do
    setup do
      @permission1 = FactoryGirl.create(:permission, :domain, :name => 'permission1')
      @permission2 = FactoryGirl.create(:permission, :architecture, :name => 'permission2')
      @role = FactoryGirl.build(:role, :permissions => [])
      @role.add_permissions! [@permission1.name, @permission2.name]
      @org1 = FactoryGirl.create(:organization)
      @org2 = FactoryGirl.create(:organization)
      @role.filters.reload
      @filter_with_org = @role.filters.detect { |f| f.allows_organization_filtering? }
      @filter_without_org = @role.filters.detect { |f| !f.allows_organization_filtering? }
    end

    describe '#sync_inheriting_filters' do
      it 'automatically propagates taxonomies to filters after save' do
        @role.organizations = [ @org1 ]
        @role.save
        @filter_with_org.reload
        assert_equal [ @org1 ], @filter_with_org.organizations
      end

      it 'automatically propagates taxonomies only to inheriting filters' do
        @filter_with_org.update_attribute :override, true
        @role.organizations = [ @org2 ]
        @role.save
        @filter_with_org.reload
        assert_empty @filter_with_org.organizations
      end

      it 'does not touch filters that do not support taxonomies' do
        @role.organizations = [ @org1 ]
        @role.save
        @filter_without_org.reload
        assert_empty @filter_without_org.organizations
        assert_nil @filter_without_org.taxonomy_search
      end

      it 'does not touch filters that do not support taxonomies even if they override' do
        @filter_without_org.update_attribute :override, true
        @role.organizations = [ @org1 ]
        @role.save
        @filter_without_org.reload
        assert_empty @filter_without_org.organizations
        assert_nil @filter_without_org.taxonomy_search
      end
    end

    describe '#disable_filters_overriding' do
      it 'disables overriding and inherits taxonomies' do
        @filter_with_org.update_attribute :override, true
        @role.organizations = [ @org1 ]
        as_admin do
          @role.disable_filters_overriding
          @filter_with_org.reload
          assert_equal [ @org1 ], @filter_with_org.organizations
          refute @filter_with_org.override
        end
      end
    end
  end
end
