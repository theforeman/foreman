require 'test_helper'

class PuppetclassesControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for Puppetclass model" do
    assert_not_nil PuppetclassesController.active_scaffold_config
    assert PuppetclassesController.active_scaffold_config.model == Puppetclass
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create new puppetclass" do
    assert_difference 'Puppetclass.count' do
      post :create, { :commit => "Create", :record => {:name => "my_puppetclass"} }
    end

    assert_redirected_to puppetclasses_path
  end

  test "should get edit" do
    puppetclass = Puppetclass.new :name => "my_puppetclass"
    assert puppetclass.save!

    get :edit, :id => puppetclass.id
    assert_response :success
  end

  test "should update puppetclass" do
    puppetclass = Puppetclass.new :name => "my_puppetclass"
    assert puppetclass.save!

    put :update, { :commit => "Update", :id => puppetclass.id, :record => {:name => "my_other_puppetclass"} }
    puppetclass = Puppetclass.find_by_id(puppetclass.id)
    assert puppetclass.name == "my_other_puppetclass"

    assert_redirected_to puppetclasses_path
  end

  test "should destroy puppetclass" do
    puppetclass = Puppetclass.new :name => "my_puppetclass"
    assert puppetclass.save!

    assert_difference('Puppetclass.count', -1) do
      delete :destroy, :id => puppetclass.id
    end

    assert_redirected_to puppetclasses_path
  end
end

