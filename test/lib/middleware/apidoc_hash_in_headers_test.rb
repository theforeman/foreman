require 'test_helper'

class ApidocHashInHeadersTest < ActiveSupport::TestCase

  def setup
    @app = mock("Target Rack Application")
    @app.stubs(:call).returns([200, { }, "Target app"])

    Rails.configuration.apipie_apidoc_hash = "0fc63869c106a448116c45ea061dd852"
  end

  test "adding apipie hash to headers" do

    middleware = Middleware::ApidocHashInHeaders.new(@app)
    code, env = middleware.call(env_for('http://admin.example.com'))

    assert_equal Rails.configuration.apipie_apidoc_hash, env["Apipie-Apidoc-Hash"]
  end

  def env_for url, opts={}
    Rack::MockRequest.env_for(url, opts)
  end

end
