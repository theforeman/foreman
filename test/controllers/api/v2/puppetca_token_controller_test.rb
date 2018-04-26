require 'test_helper'

class Api::V2::PuppetcaTokenControllerTest < ActionController::TestCase
  let(:host) { FactoryBot.create(:host, :managed, :with_puppetca_token) }

  test "should not destroy puppetca-tokens when value doesnt exist" do
    assert_difference('Token::Puppetca.count', 0) do
      delete :destroy, params: { :id => "(doesn't exist)" }
    end
    assert_response :not_found
  end

  test "should not destroy puppetca-tokens when host not in build" do
    assert_difference('Token::Puppetca.count', 1) do
      delete :destroy, params: { :id => host.puppetca_token.value }
    end
    assert_response :not_found
  end

  test "should destroy puppetca-tokens" do
    host.build = true
    host.save
    assert_difference('Token::Puppetca.count', -1) do
      delete :destroy, params: { :id => host.puppetca_token.value }
    end
    assert_response :no_content
  end
end
