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

  test 'get index' do
    get :index, {}, set_session_user
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:roles)
    assert_equal Role.all.sort, [assigns(:roles)].flatten.sort

    assert_tag :tag => 'a', :attributes => { :href => '/roles/1-Manager/edit' },
      :content => 'Manager'
  end

  test 'get new' do
    get :new, {}, set_session_user
    assert_response :success
    assert_template 'new'
  end

  test 'empty name validation' do
    post :create, { :role => {:name => ''}}, set_session_user

    assert_response :success
    assert_template 'new'
  end

  test 'creates role' do
    post :create, { :role => {:name => 'test role'}}, set_session_user

    assert_redirected_to roles_path
    assert Role.find_by_name('test role')
  end

  test 'get edit goes to right template' do
    get :edit, {:id => 1}, set_session_user
    assert_response :success
    assert_template 'edit'
    assert_equal Role.find(1), assigns(:role)
  end

  test 'put edit updates role' do
    role = FactoryGirl.create(:role)
    put :update, {:id => role.id, :role => {:name => 'masterManager'}}, set_session_user

    assert_redirected_to roles_path
    role.reload
    assert_equal 'masterManager', role.name
  end

  test 'delete destroy removes role' do
    role = FactoryGirl.build(:role, :name => 'ToBeDestroyed')
    role.add_permissions! :view_ptables

    delete :destroy, {:id => role}, set_session_user
    assert_redirected_to roles_path
    assert_nil Role.find_by_id(role.id)
  end

  test 'roles in use cannot be destroyed' do
    users(:one).roles = [roles(:manager)] # make user one a manager
    delete :destroy, {:id => roles(:manager)}, set_session_user
    assert_redirected_to roles_path
    assert_equal 'Role is in use', flash[:error]
    assert_not_nil Role.find_by_id(roles(:manager).id)
  end

  context 'clone' do
    setup do
      @role = FactoryGirl.build(:role, :name => 'ToBeDestroyed')
      @role.add_permissions! :view_ptables
    end

    test 'renders new page with hidden field original_role_id' do
      get :clone, { :id => @role.id }, set_session_user
      assert_template 'new'
    end

    test 'original_role_id is used to create cloned role if set' do
      params = { :role => {:name => 'clonedrole'},
                 :original_role_id => @role.id,
                 :cloned_role => true }
      post :create, params, set_session_user
      assert_redirected_to roles_url

      cloned_role = Role.find_by_name('clonedrole')
      assert_not_nil cloned_role
      assert_equal @role.permissions, cloned_role.permissions
    end
  end

end
