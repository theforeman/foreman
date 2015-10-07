require 'test_helper'
require 'aspect_test_helper'

class HostAspectsHelperTest < ActionView::TestCase
  class TestAspect < HostAspectBase
  end

  module TestableHelper
    def host_additional_tabs(host, form)
      {}
    end
  end

  # Make super calls on aspects helper available.
  include TestableHelper
  include HostAspectsHelper

  context 'aspects related' do
    setup do
      @host_form = mock('host_form')
      @aspect_model = TestAspect.new
      self.expects(:render).with() { |val, locals| val == @aspect_model && locals[:f] == @host_form }.returns("tab stub")
    end

    test '#aspect_tab creates a valid tab' do
      html = aspect_tab(:my_subject, @aspect_model, @host_form)

      assert_match /tab stub/, html
      assert_match /tab-pane/, html
    end

    test '#load_aspects returns hash of subjects to displayable tabs' do
      host = Host::Managed.new
      ha = host.host_aspects.build(:aspect_subject => :my_subject)
      ha.execution_model = @aspect_model

      aspects_hash = load_aspects(host, @host_form)

      aspect_tab = aspects_hash[:my_subject]
      assert_not_nil aspect_tab
    end

    test '#host_additional_tabs returns all aspects' do
      host = Host::Managed.new
      ha = host.host_aspects.build(:aspect_subject => :my_subject)
      ha.execution_model = @aspect_model

      aspects_hash = host_additional_tabs(host, @host_form)

      aspect_tab = aspects_hash[:my_subject]
      assert_not_nil aspect_tab
    end
  end
end