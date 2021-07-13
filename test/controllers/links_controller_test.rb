require 'test_helper'

class LinksControllerTest < ActionController::TestCase
  describe 'documentation' do
    test '#documentation_url returns global url if no section specified' do
      get :show, params: { type: 'manual' }

      assert_redirected_to /index.html/
    end

    test '#documentation_url returns foreman docs url with a given section' do
      get :show, params: { type: 'manual', section: '1.1TestSection' }

      assert_redirected_to /TestSection/
      assert_redirected_to /manuals/
    end

    test '#documentation_url receives a root_url option' do
      get :show, params: {
        type: 'manual',
        section: '2.2PluginSection',
        root_url: 'http://www.theforeman.org/my_plugin/v0.1/index.html#',
      }

      assert_redirected_to /PluginSection/
      assert_redirected_to /my_plugin/
    end

    test '#plugin_documentation_url returns foreman docs url for a plugin with a version and a given section' do
      get :show, params: {
        type: 'plugin_manual',
        name: 'foreman_discovery',
        version: '15.0',
        section: '#4.Usage',
      }

      assert_redirected_to /plugins/
      assert_redirected_to /foreman_discovery/
      assert_redirected_to /15.0/
      assert_redirected_to /Usage/
    end

    test '#plugin_documentation_url and new docs page' do
      get :show, params: {
        type: 'docs',
        section: 'TestSection',
        chapter: 'TestChapter',
      }

      assert_redirected_to /docs.theforeman.org/
      assert_redirected_to /TestSection/
      assert_redirected_to /foreman-el/
      assert_redirected_to /#TestChapter/
    end
  end
end
