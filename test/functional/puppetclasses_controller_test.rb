require 'test_helper'

class PuppetclassesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Puppetclass.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Puppetclass.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to puppetclasses_url
  end

  def test_edit
    get :edit, :id => Puppetclass.first
    assert_template 'edit'
  end

  def test_update_invalid
    Puppetclass.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Puppetclass.first
    assert_template 'edit'
  end

  def test_update_valid
    Puppetclass.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Puppetclass.first
    assert_redirected_to puppetclasses_url
  end

  def test_destroy
    puppetclass = Puppetclass.first
    delete :destroy, :id => puppetclass
    assert_redirected_to puppetclasses_url
    assert !Puppetclass.exists?(puppetclass.id)
  end
end
