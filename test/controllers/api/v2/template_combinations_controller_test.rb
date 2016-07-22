require 'test_helper'

class Api::V2::TemplateCombinationsControllerTest < ActionController::TestCase
  include ForemanTasks::TestHelpers::WithInThreadExecutor
  context 'with provisioning_template_id' do
    setup do
      Foreman::Deprecation.expects(:api_deprecation_warning).never
    end

    test "should get index" do
      get :index, {:provisioning_template_id => templates(:mystring2).id}
      template_combinations = ActiveSupport::JSON.decode(@response.body)
      assert_equal 2, template_combinations['results'].size, "Should contain template_combinations in the response"
      assert_response :success
    end

    test "should get template combination" do
      get :show, { :provisioning_template_id => templates(:mystring2).to_param, :id => template_combinations(:two).id }
      assert_response :success
      template_combination = ActiveSupport::JSON.decode(@response.body)
      assert !template_combination.empty?
      assert_equal template_combination["provisioning_template_id"], template_combinations(:two).provisioning_template_id
    end

    test "should create valid" do
      TemplateCombination.any_instance.stubs(:valid?).returns(true)
      as_admin do
        post :create, { :template_combination => { :environment_id => environments(:production).id, :hostgroup_id => hostgroups(:unusual).id },
          :provisioning_template_id => templates(:mystring2).id }
      end
      template_combination = ActiveSupport::JSON.decode(@response.body)
      assert_equal(template_combination["environment_id"], environments(:production).id)
      assert_equal(template_combination["hostgroup_id"], hostgroups(:unusual).id)
      assert_equal(template_combination["provisioning_template_id"], templates(:mystring2).id)
      assert_response :created
    end

    test "should update template combination" do
      put :update, { :template_combination => { :environment_id => environments(:testing).id, :hostgroup_id => hostgroups(:common).id },
                     :provisioning_template_id => templates(:mystring2).id, :id => template_combinations(:two).id }

      template_combination = ActiveSupport::JSON.decode(@response.body)
      assert_equal(template_combination["environment_id"], environments(:testing).id)
      assert_equal(template_combination["hostgroup_id"], hostgroups(:common).id)
      assert_response :success
    end

    test "should destroy" do
      delete :destroy, { :provisioning_template_id => templates(:mystring2).id, :id => template_combinations(:two).id }
      assert_response :ok
      refute TemplateCombination.exists?(template_combinations(:two).id)
    end
  end

  context 'with deprecated config_template_id' do
    setup do
      Foreman::Deprecation.expects(:api_deprecation_warning).with('Config templates were renamed to provisioning templates')
    end

    test "should get index" do
      get :index, {:config_template_id => templates(:mystring2).id}
      template_combinations = ActiveSupport::JSON.decode(@response.body)
      assert_equal 2, template_combinations['results'].size, "Should contain template_combinations in the response"
      assert_response :success
    end

    test "should get template combination" do
      get :show, { :config_template_id => templates(:mystring2).to_param, :id => template_combinations(:two).id }
      assert_response :success
      template_combination = ActiveSupport::JSON.decode(@response.body)
      assert !template_combination.empty?
      assert_equal template_combination["config_template_id"], template_combinations(:two).provisioning_template_id
    end

    test "should create valid" do
      TemplateCombination.any_instance.stubs(:valid?).returns(true)
      as_admin do
        post :create, { :template_combination => { :environment_id => environments(:production).id, :hostgroup_id => hostgroups(:unusual).id },
          :config_template_id => templates(:mystring2).id }
      end
      template_combination = ActiveSupport::JSON.decode(@response.body)
      assert_equal(template_combination["environment_id"], environments(:production).id)
      assert_equal(template_combination["hostgroup_id"], hostgroups(:unusual).id)
      assert_equal(template_combination["config_template_id"], templates(:mystring2).id)
      assert_response :created
    end

    test "should update template combination" do
      put :update, { :template_combination => { :environment_id => environments(:testing).id, :hostgroup_id => hostgroups(:common).id },
                     :config_template_id => templates(:mystring2).id, :id => template_combinations(:two).id }

      template_combination = ActiveSupport::JSON.decode(@response.body)
      assert_equal(template_combination["environment_id"], environments(:testing).id)
      assert_equal(template_combination["hostgroup_id"], hostgroups(:common).id)
      assert_response :success
    end

    test "should destroy" do
      delete :destroy, { :config_template_id => templates(:mystring2).id, :id => template_combinations(:two).id }
      assert_response :ok
      refute TemplateCombination.exists?(template_combinations(:two).id)
    end
  end

  context 'unnested combinations' do
    test "should get template combination directly" do
      get :show, { :id => template_combinations(:two).id }
      assert_response :success
      template_combination = ActiveSupport::JSON.decode(@response.body)
      assert !template_combination.empty?
      assert_equal template_combination["provisioning_template_id"], template_combinations(:two).provisioning_template_id
    end

    test "should destroy directly" do
      delete :destroy, { :id => template_combinations(:two).id }
      assert_response :ok
      refute TemplateCombination.exists?(template_combinations(:two).id)
    end
  end
end
