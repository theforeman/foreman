require 'test_helper'

class LinksControllerTest < ActionController::TestCase
  describe 'documentation' do
    test '#documentation_url returns global url if no section specified on develop' do
      with_temporary_settings(version: Foreman::Version.new('3.10-develop')) do
        get :show, params: { type: 'manual' }

        assert_redirected_to 'https://theforeman.org/manuals/nightly/index.html#'
      end
    end

    test '#documentation_url returns global url if no section specified on stable' do
      with_temporary_settings(version: Foreman::Version.new('3.9.1')) do
        get :show, params: { type: 'manual' }

        assert_redirected_to 'https://theforeman.org/manuals/3.9/index.html#'
      end
    end

    test '#documentation_url returns foreman docs url with a given section' do
      with_temporary_settings(version: Foreman::Version.new('3.10-develop')) do
        get :show, params: { type: 'manual', section: '1.1TestSection' }

        assert_redirected_to 'https://theforeman.org/manuals/nightly/index.html#1.1TestSection'
      end
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

    test '#documentation_url receives an allowed root_url domain' do
      ['theforeman.org', 'redhat.com', 'orcharhino.com'].each do |domain|
        get :show, params: {
          type: 'manual',
          root_url: "http://#{domain}",
        }

        assert_redirected_to /#{domain}/
      end
    end

    test '#documentation_url receives an allowed root_url subdomain' do
      ['theforeman.org', 'redhat.com', 'orcharhino.com'].each do |domain|
        get :show, params: {
          type: 'manual',
          root_url: "http://some-sub.#{domain}",
        }

        assert_redirected_to /some-sub.#{domain}/
      end
    end

    test '#documentation_url receives a forbidden root_url option' do
      get :show, params: {
        type: 'manual',
        root_url: 'http://www.example.invalid',
      }

      assert_response :not_found
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

    test 'new docs on nightly' do
      with_temporary_settings(version: Foreman::Version.new('3.10-develop')) do
        get :show, params: {
          type: 'docs',
          section: 'TestSection',
          chapter: 'TestChapter',
        }

        assert_redirected_to %r{https://docs\.theforeman\.org/nightly/TestSection/index-(foreman-(deb|el)|katello)\.html#TestChapter}
      end
    end

    test 'new docs on a stable release' do
      with_temporary_settings(version: Foreman::Version.new('3.9.1')) do
        get :show, params: {
          type: 'docs',
          section: 'TestSection',
          chapter: 'TestChapter',
        }

        assert_redirected_to %r{https://docs\.theforeman\.org/3\.9/TestSection/index-(foreman-(deb|el)|katello)\.html#TestChapter}
      end
    end

    describe '#new_docs_flavor' do
      test 'on Enterprise Linux' do
        Foreman::Plugin.stubs(:installed?).with('katello').returns(false)
        with_temporary_settings(docs_os_flavor: 'foreman-el') do
          assert_equal(LinksController.new_docs_flavor, 'foreman-el')
        end
      end

      test 'on Debian' do
        Foreman::Plugin.stubs(:installed?).with('katello').returns(false)
        with_temporary_settings(docs_os_flavor: 'foreman-deb') do
          assert_equal(LinksController.new_docs_flavor, 'foreman-deb')
        end
      end

      test 'on Enterprise Linux with Katello' do
        Foreman::Plugin.stubs(:installed?).with('katello').returns(true)
        with_temporary_settings(docs_os_flavor: 'foreman-el') do
          assert_equal(LinksController.new_docs_flavor, 'katello')
        end
      end
    end
  end
end
