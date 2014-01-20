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

  def test_get_index
    get :index, {}, set_session_user
    assert_response :success
    assert_template 'index'

    assert_not_nil assigns(:roles)
    assert_equal Role.all.sort, [assigns(:roles)].flatten.sort

    assert_tag :tag => 'a', :attributes => { :href => '/roles/1/edit' },
      :content => 'Manager'
  end

  def test_get_new
    get :new, {}, set_session_user
    assert_response :success
    assert_template 'new'
  end

  def test_post_new_with_validaton_failure
    post :create, { :role => {:name => ''}}, set_session_user

    assert_response :success
    assert_template 'new'
  end

  def test_get_edit
    get :edit, {:id => 1}, set_session_user
    assert_response :success
    assert_template 'edit'
    assert_equal Role.find(1), assigns(:role)
  end

  def test_post_edit
    r = FactoryGirl.create(:role)
    put :update, {:id => r.id, :role => {:name => 'masterManager'}}, set_session_user

    assert_redirected_to roles_path
    r.reload
    assert_equal 'masterManager', r.name
  end

  def test_destroy
    r = FactoryGirl.build(:role, :name => 'ToBeDestroyed')
    r.add_permissions! :view_ptables

    delete :destroy, {:id => r}, set_session_user
    assert_redirected_to roles_path
    assert_nil Role.find_by_id(r.id)
  end

  def test_destroy_role_in_use
    users(:one).roles = [roles(:manager)] # make user one a manager
    delete :destroy, {:id => roles(:manager)}, set_session_user
    assert_redirected_to roles_path
    assert_equal 'Role is in use', flash[:error]
    assert_not_nil Role.find_by_id(roles(:manager).id)
  end

end
