require 'test_helper'

module Api
  module V2
    class TemplateInputsControllerTest < ActionController::TestCase
      setup do
        @template = FactoryBot.create(:report_template, :with_input)
        @input = @template.template_inputs.first
      end

      test 'should get index' do
        get :index, params: { :template_id => @template.id }
        inputs = ActiveSupport::JSON.decode(@response.body)
        assert !inputs.empty?, 'Should respond with inputs'
        assert_response :success
      end

      test 'should get input detail' do
        get :show, params: { :template_id => @template.to_param, :id => @input.to_param }
        assert_response :success
        input = ActiveSupport::JSON.decode(@response.body)
        assert !input.empty?
        assert_equal input['name'], @input.name
      end

      test 'should create valid' do
        valid_attrs = { :name => 'is_potato', :input_type => 'user', :options => ['true', 'false'] }
        post :create, params: { :template_input => valid_attrs, :template_id => @template.to_param }
        input = ActiveSupport::JSON.decode(@response.body)
        assert input['name'] == 'is_potato'
        assert_response :success
      end

      test 'should not create invalid' do
        post :create, params: { :template_id => @template.to_param }
        assert_response :unprocessable_entity
      end

      test 'should update valid' do
        put :update, params: { :template_id => @template.to_param, :id => @input.to_param, :template_input => { :name => 'blah' } }
        assert_response :ok
      end

      test 'should not update invalid' do
        put :update, params: { :template_id => @template.to_param, :id => @input.to_param, :template_input => { :name => '' } }
        assert_response :unprocessable_entity
      end

      test 'should destroy' do
        delete :destroy, params: { :template_id => @template.to_param, :id => @input.to_param }
        assert_response :ok
        refute TemplateInput.exists?(@input.id)
      end
    end
  end
end
