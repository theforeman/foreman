# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
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

require 'test_helper'

class RolesControllerTest < ActionController::TestCase
  setup do
    @model = Role.first
  end

  basic_index_test('roles')
  basic_new_test
  basic_edit_test
  basic_pagination_per_page_test
  basic_pagination_rendered_test

  test 'creates role' do
    post :create, params: { :role => {:name => 'test role'} }, session: set_session_user

    assert_redirected_to roles_path
    assert Role.find_by_name('test role')
  end

  test 'put edit updates role' do
    role = FactoryBot.create(:role)
    put :update, params: { :id => role.id, :role => {:name => 'masterManager'} }, session: set_session_user

    assert_redirected_to roles_path
    role.reload
    assert_equal 'masterManager', role.name
  end

  test 'delete destroy removes role' do
    role = FactoryBot.build(:role, :name => 'ToBeDestroyed')
    role.add_permissions! :view_ptables

    delete :destroy, params: { :id => role }, session: set_session_user
    assert_redirected_to roles_path
    assert_nil Role.find_by_id(role.id)
  end

  test 'builtin roles cannot be destroyed' do
    users(:one).roles = [roles(:default_role)] # make user one a manager
    delete :destroy, params: { :id => roles(:default_role) }, session: set_session_user
    assert_redirected_to roles_path
    assert_equal "Cannot delete built-in role", flash[:error]
    assert_not_nil Role.find_by_id(roles(:default_role).id)
  end

  context "with taxonomies" do
    before do
      @permission1 = FactoryBot.create(:permission, :domain, :name => 'permission1')
      @role = FactoryBot.build(:role, :permissions => [])
      @role.add_permissions! [@permission1.name]
      @org1 = FactoryBot.create(:organization)
      @org2 = FactoryBot.create(:organization)
      @role.organizations = [@org1]
    end

    test 'should disable filter overriding' do
      @role.filters.reload
      @filter_with_org = @role.filters.detect { |f| f.resource_taxable_by_organization? }
      @filter_with_org.update :organizations => [@org1, @org2], :override => true

      patch :disable_filters_overriding, params: { :id => @role.id }, session: set_session_user
      @filter_with_org.reload

      assert_response :redirect
      assert_equal [@org1], @filter_with_org.organizations
      refute @filter_with_org.override?
    end

    test 'update syncs filters taxonomies if configuration changed' do
      put :update, params: { :id => @role.id, :role => { :organization_ids => ['', @org2.id.to_s, ''] } }, session: set_session_user
      assert_response :redirect
      filter = @role.filters.first
      assert_equal [@org2], filter.organizations.all
    end

    test 'sets new taxonomies to filters after cloning properly' do
      params = { :role => { :name => 'clonedrole', :organization_ids => ['', @org2.id.to_s, ''] },
                 :original_role_id => @role.id,
                 :cloned_role => true }
      post :create, params: params, session: set_session_user

      assert_response :redirect
      filter = Role.find_by_name('clonedrole').filters.first
      assert_equal [@org2], filter.organizations.all
    end
  end

  context 'clone' do
    setup do
      @role = FactoryBot.build(:role, :name => 'ToBeDestroyed')
      @role.add_permissions! :view_ptables
    end

    test 'renders new page with hidden field original_role_id' do
      get :clone, params: { :id => @role.id }, session: set_session_user
      assert_template 'new'
    end

    test 'original_role_id is used to create cloned role if set' do
      params = { :role => {:name => 'clonedrole'},
                 :original_role_id => @role.id,
                 :cloned_role => true }
      post :create, params: params, session: set_session_user
      assert_redirected_to roles_url

      cloned_role = Role.find_by_name('clonedrole')
      assert_not_nil cloned_role
      assert_equal @role.permissions, cloned_role.permissions
      assert_equal cloned_role.builtin, 0
    end
  end
end
