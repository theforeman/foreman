require 'test_helper'

class DomainsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create domain" do
    assert_difference('Domain.count') do
      post :create, { :commit => "Create", :record => { :name => "my_domain" } }
    end

    assert_redirected_to domains_path
  end

   test "should show domain" do
    domain = Domain.create :name => "my_domain"
    assert domain.save!

    get :show, :id => domain.id
    assert_response :success
   end

  test "should get edit" do
    domain = Domain.create :name => "my_domain"
    assert domain.save!
    get :edit, :id => domain.id
    assert_response :success
  end

  test "should update domain" do
    domain = Domain.create :name => "my_domain"
    assert domain.save!

    put :update, { :commit => "Update", :id => domain.id, :record => {:name => "our_domain"} }
    domain = Domain.find_by_id(domain.id)
    assert domain.name == "our_domain"

    assert_redirected_to domains_path
  end

  test "should destroy domain" do
    domain = Domain.create :name => "my_domain"
    assert domain.save!
    assert_difference('Domain.count', -1) do
      delete :destroy, :id => domain.id
    end

    assert_redirected_to domains_path
  end
end

