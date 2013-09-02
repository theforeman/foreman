require 'test_helper'

class Api::V2::StatisticsControllerTest < ActionController::TestCase

  test "should get statistics" do
    get :index, { }
    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert !response.empty?
    assert response.keys.include?('os_count')
    assert response.keys.include?('arch_count')
    assert response.keys.include?('env_count')
    assert response.keys.include?('klass_count')
    assert response.keys.include?('cpu_count')
    assert response.keys.include?('model_count')
    assert response.keys.include?('mem_size')
    assert response.keys.include?('mem_free')
    assert response.keys.include?('swap_size')
    assert response.keys.include?('swap_free')
    assert response.keys.include?('mem_totsize')
    assert response.keys.include?('mem_totfree')
  end

end
