require 'test_helper'
require 'ostruct'

class RablTest < ActiveSupport::TestCase
  test 'render of single template' do
    @media = FactoryBot.build_stubbed(:medium)
    rendered = Rabl.render(@media,
      'api/v2/media/show',
      :format => :json,
      :view_path => 'app/views')
    loaded = JSON.load(rendered)
    assert_equal Hash, loaded.class
    assert_equal @media.name, loaded['name']
  end

  test 'render of collection template' do
    rendered = Rabl.render([OpenStruct.new(:name => 'foo', :registered_smart_proxies => {})],
      'api/v2/domains/index',
      :format => :json,
      :view_path => 'app/views')
    loaded = JSON.load(rendered)
    assert_equal Array, loaded.class
    assert_equal Hash, loaded[0].class
    assert_equal 'foo', loaded[0]['name']
  end

  context 'with plugin' do
    setup :clear_plugins
    teardown :restore_plugins

    test 'render of extended plugin template' do
      Foreman::Plugin.register :test_extend_rabl_template do
        extend_rabl_template 'api/v2/test/one', 'api/v2/test/two'
      end
      @media = FactoryBot.build_stubbed(:medium)
      rendered = Rabl.render(@media,
        'api/v2/test/one',
        :format => :json,
        :view_path => File.expand_path('../../test/static_fixtures/views', __dir__))
      loaded = JSON.load(rendered)
      assert_equal Hash, loaded.class
      assert_equal @media.name, loaded['name']
      assert_equal '1', loaded['one']
      assert_equal '2', loaded['two']
    end
  end
end
