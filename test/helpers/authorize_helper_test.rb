require 'test_helper'

class AuthorizeHelperTest < ActionView::TestCase
  HelperTestDummy = Class.new { include AuthorizeHelper }
  subject { HelperTestDummy.new }
  let(:authorizer) { mock('Authorizer') }
  let(:controller_name) { 'test' }

  describe '#authorized_for' do
    describe 'permission inference' do
      it 'infer permission for core controllers' do
        host = mock('Host')
        authorizer.expects(:can?).with('edit_hosts', host)
        subject.authorized_for(authorizer: authorizer, auth_object: host, controller: 'hosts', action: 'edit')
      end

      it 'infer permission for isolated engine controllers' do
        plugin_resource = mock('PluginResource')
        authorizer.expects(:can?).with('edit_plugin_resource', plugin_resource)
        subject.authorized_for(authorizer: authorizer, auth_object: plugin_resource, controller: 'plugin_name/plugin_resource', action: 'edit')
      end
    end
  end
end
