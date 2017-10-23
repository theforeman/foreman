require 'test_helper'

class HttpProxyTest < ActiveSupport::TestCase
  let(:http_proxy) {FactoryBot.create(:http_proxy)}

  should validate_presence_of(:url)
  should_not allow_value('börks').for(:url)

  test 'create' do
    proxy = HttpProxy.new(:name => 'foobar', :url => "http://someurl:5000")

    assert proxy.save
  end

  test 'search by name' do
    assert_equal 1, HttpProxy.search_for("name = #{http_proxy.name}").count
  end
end
