require 'test_helper'

class PtablesControllerTest < ActionController::TestCase
  test "ActiveScaffold should look for Ptable model" do
    assert_not_nil PtablesController.active_scaffold_config
    assert PtablesController.active_scaffold_config.model == Ptable
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "shuold get new" do
    get :new
    assert_response :success
  end

  test "should create new partition table" do
    assert_difference 'Ptable.count' do
      post :create, { :commit => "Create", :record => {:name => "some_partition_table", :layout => "some_layout"} }
    end

    assert_redirected_to '/ptables'
  end

  test "should get edit" do
    partition_table = Ptable.new :name => "some_partition_table", :layout => "some_layout"
    assert partition_table.save!

    get :edit, :id => partition_table.id
    assert_response :success
  end

  test "should update partition table" do
    partition_table = Ptable.new :name => "some_partition_table", :layout => "some_layout"
    assert partition_table.save!

    put :update, { :commit => "Update", :id => partition_table.id, :record => {:name => "other_partition_table", :layout => "some_other_layout"} }
    partition_table = Ptable.find_by_id(partition_table.id)
    assert partition_table.name == "other_partition_table"
    assert partition_table.layout == "some_other_layout"

    assert_redirected_to '/ptables'
  end

  test "should destroy partition table" do
    partition_table = Ptable.new :name => "some_partition_table", :layout => "some_layout"
    assert partition_table.save!

    assert_difference('Ptable.count', -1) do
      delete :destroy, :id => partition_table.id
    end

    assert_redirected_to '/ptables'
  end
end
