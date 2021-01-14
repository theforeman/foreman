require 'test_helper'

class HttpProxyTest < ActiveSupport::TestCase
  let(:http_proxy) { FactoryBot.create(:http_proxy) }

  should validate_presence_of(:url)
  should_not allow_value('börks').for(:url)

  test 'create' do
    proxy = HttpProxy.new(:name => 'foobar', :url => "http://someurl:5000")

    assert proxy.save
  end

  # the form sends empty string for the username and password fields
  # backend systems may have problems detecting the empty string as a no-value
  # so we should must keep them as nil
  test 'create with empty username' do
    proxy = HttpProxy.new(:name => 'foobar', :url => "http://someurl:5000", :username => '', :password => '')

    assert proxy.save
    assert_nil proxy.username
    assert_nil proxy.password
  end

  test 'search by name' do
    assert_equal 1, HttpProxy.search_for("name = #{http_proxy.name}").count
  end

  context 'is audited' do
    test 'on creation on of a new http_proxy' do
      http_proxy = FactoryBot.build(:http_proxy, :with_auditing)

      assert_difference 'http_proxy.audits.count' do
        http_proxy.save!
      end
    end
  end
end
