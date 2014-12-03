require 'test_helper'
require 'ostruct'

class RablTest < ActiveSupport::TestCase
  test 'render of single template' do
    @domain = FactoryGirl.build(:domain)
    rendered = Rabl.render(@domain,
                           'api/v2/domains/show',
                           :format => :json,
                           :view_path => 'app/views')
    loaded = JSON.load(rendered)
    assert_equal Hash, loaded.class
    assert_equal @domain.name, loaded['name']
  end

  test 'render of collection template' do
    rendered = Rabl.render([OpenStruct.new(:name => 'foo')],
                           'api/v2/domains/index',
                           :format => :json,
                           :view_path => 'app/views')
    loaded = JSON.load(rendered)
    assert_equal Array, loaded.class
    assert_equal Hash, loaded[0].class
    assert_equal 'foo', loaded[0]['name']
  end
end
