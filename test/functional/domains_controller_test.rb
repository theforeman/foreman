require 'test_helper'

class DomainsControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Domain.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Domain.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to domains_url
  end

  def test_edit
    get :edit, :id => Domain.first
    assert_template 'edit'
  end

  def test_update_invalid
    Domain.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Domain.first
    assert_template 'edit'
  end

  def test_update_valid
    Domain.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Domain.first
    assert_redirected_to domains_url
  end

  def test_destroy
    domain = Domain.first
    delete :destroy, :id => domain
    assert_redirected_to domains_url
    assert !Domain.exists?(domain.id)
  end
end
