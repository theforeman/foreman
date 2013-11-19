require 'test_helper'
require 'rest-client'
require 'capybara/rails'

class CatchJsonParseErrorsTest < ActiveSupport::TestCase
  def setup
    Capybara.current_driver = :selenium
  end

  test "submitting invalid JSON" do

    broken_json = "{notAJson"
    body = post_broken_json_to_api('/api/systems', broken_json)

    response = ActiveSupport::JSON.decode(body)
    assert_equal 400, response['status']
    assert_match 'There was a problem in the JSON you submitted:', response['error']
  end

  private

  def post_broken_json_to_api(path, broken_json)
    RestClient.post("http://#{system}:#{port}#{path}", broken_json, default_headers)
  rescue RestClient::BadRequest => e
    e.response
  end

  def system
    Capybara.current_session.server.system
  end

  def port
    Capybara.current_session.server.port
  end

  def default_headers
    {
      'Accept'       => 'application/json,version=2',
      'Content-Type' => 'application/json'
    }
  end

end