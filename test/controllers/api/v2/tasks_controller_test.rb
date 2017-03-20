require 'test_helper'

class Api::V2::TasksControllerTest < ActionController::TestCase
  test 'should not get index without an id' do
    get :index, params: { :id => nil }
    assert_response :not_found

    get :index, params: { :id => '' }
    assert_response :not_found

    get :index, params: { :id => "Random-#{Foreman.uuid}" }
    assert_response :not_found
  end

  test 'should get index' do
    uuid = Foreman.uuid

    queue = Orchestration::Queue.new
    queue.create(:name => 'create something', :priority => 10, :action => [Object.new, :to_s])
    Rails.cache.write(uuid, queue.to_json)

    get :index, params: { :id => uuid }
    tasks = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 1, tasks['results'].size
    task = tasks['results'].first
    assert_equal 'create something', task['name']
    assert_equal 'pending', task['status']
    assert_equal 10, task['priority']
    assert Time.now.utc - Time.parse(task['timestamp']).utc < 5.seconds
  end
end
