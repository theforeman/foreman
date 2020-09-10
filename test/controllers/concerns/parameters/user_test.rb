require 'test_helper'

class UserParametersTest < ActiveSupport::TestCase
  include Foreman::Controller::Parameters::User

  let(:context) { Foreman::Controller::Parameters::User::Context.new(:api, 'user', 'update', editing_self) }

  context "editing another user" do
    let(:editing_self) { false }

    test "permits :admin if current user is an admin" do
      params = ActionController::Parameters.new(:user => {:admin => true})
      as_admin do
        assert_includes self.class.user_params_filter.filter_params(params, context), 'admin'
      end
    end

    test "blocks :admin if current user is not an admin" do
      params = ActionController::Parameters.new(:user => {:admin => true})
      as_user(FactoryBot.create(:user)) do
        refute_includes self.class.user_params_filter.filter_params(params, context), 'admin'
      end
    end

    test "permits role attributes" do
      params = ActionController::Parameters.new(:user => {:roles => ['a'], :role_ids => [1], :role_names => ['a']})
      filtered = as_admin { self.class.user_params_filter.filter_params(params, context) }
      assert_includes filtered, 'roles'
      assert_includes filtered, 'role_ids'
      assert_includes filtered, 'role_names'
    end
  end

  context "editing self" do
    let(:editing_self) { true }

    test "blocks role attributes" do
      params = ActionController::Parameters.new(:user => {:roles => ['a'], :role_ids => [1], :role_names => ['a']})
      as_user(FactoryBot.create(:user)) do
        assert_empty self.class.user_params_filter.filter_params(params, context)
      end
    end
  end
end
