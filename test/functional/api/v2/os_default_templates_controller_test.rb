require 'test_helper'

class Api::V2::OsDefaultTemplatesControllerTest < ActionController::TestCase
  test 'should get os_default_templates for os' do
    get :index, {:operatingsystem_id => operatingsystems(:redhat).to_param }
    assert_response :success
    assert_not_nil assigns(:os_default_templates)
    results = ActiveSupport::JSON.decode(@response.body)
    assert_equal 6, results['results'].length
  end

  test 'should show os_default_template' do
    get :show, { :operatingsystem_id => operatingsystems(:redhat).to_param, :id => os_default_templates(:one) }
    assert_response :success
    assert_not_nil assigns(:os_default_template)
    show_response = ActiveSupport::JSON.decode(@response.body)
    assert !show_response.empty?
  end

  test 'should create os_default_template for os' do
    # remove all os default templates and then create one below
    OsDefaultTemplate.delete_all
    assert_difference('OsDefaultTemplate.count') do
      post :create, { :operatingsystem_id => operatingsystems(:redhat).to_param, :os_default_template => {:config_template_id => config_templates(:mystring).id,
                                                                                                          :template_kind_id => template_kinds(:ipxe).id}
                    }
    end
    assert_response :success
    assert_not_nil assigns(:os_default_template)
  end

  test 'should update os_default_template for os' do
    # current fixtures has pxekickstart for PXELinux template kind.  Update it to pxe_local_default
    put :update, { :operatingsystem_id => operatingsystems(:redhat).to_param,  :id => os_default_templates(:one),
                   :os_default_template => {:config_template_id => config_templates(:pxe_local_default).id, :template_kind_id => template_kinds(:pxelinux).id}
                    }
    assert_response :success
    assert_not_nil assigns(:os_default_template)
    response = ActiveSupport::JSON.decode(@response.body)
    assert !response.empty?
    assert_equal response['config_template_id'], config_templates(:pxe_local_default).id
  end

  test 'should destroy os_default_template for os' do
    assert_difference('OsDefaultTemplate.count', -1) do
      delete :destroy, { :operatingsystem_id => operatingsystems(:redhat).to_param, :id => os_default_templates(:one) }
    end
    assert_response :success
  end
end
