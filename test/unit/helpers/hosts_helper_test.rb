require 'test_helper'

class FormHelperTest < ActionView::TestCase
  class SubjectMock
    include HostsHelper
    attr_accessor :params, :force_inherited_params
  end

  before do
    @subject = SubjectMock.new
    @subject.params = {}
    @subject.force_inherited_params = false
    @host = mock()
    @host.stubs(:hostgroup).returns(true)
    @host.stubs(:hostgroup_id_was).returns(true)
  end

  test 'field not inherited for host with changed hostgroup' do
    refute @subject.inherited_by_default?(:some_field, @host)
  end

  test 'field inheritance can be forced' do
    @subject.force_inherited_params = true
    assert @subject.inherited_by_default?(:some_field, @host)
  end
end
