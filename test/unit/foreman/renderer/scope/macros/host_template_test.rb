require 'test_helper'

class HostTemplateTest < ActiveSupport::TestCase
  setup do
    host = FactoryBot.build_stubbed(:host)
    @subject = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Macros::HostTemplate
    end.send(:new, host: host)
  end

  describe '#host_enc' do
    test 'should have host_enc helper' do
      host = FactoryBot.build(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      assert @subject.host_enc
    end

    test "should find path in host_enc" do
      host = FactoryBot.build(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      assert_equal host.puppetmaster, @subject.host_enc('parameters', 'puppetmaster')
    end

    test "should raise rendering exception if no such parameter exists while rendering host_enc" do
      host = FactoryBot.build(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      assert_raises(Foreman::Renderer::Errors::HostENCParamUndefined) do
        assert_equal host.puppetmaster, @subject.host_enc('parameters', 'puppetmaster_that_does_not_exist')
      end
    end

    test 'should raise rendering exception if @host is not set while rendering host_enc' do
      @subject.instance_variable_set('@host', nil)
      assert_raises(Foreman::Renderer::Errors::HostUnknown) do
        @subject.host_enc('parameters', 'puppetmaster')
      end
    end
  end

  describe '#host_param' do
    test 'should render host param using "host_param" helper' do
      host = FactoryBot.build(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      assert @subject.host_param('test').present?
    end

    test 'should render host param using "host_param" helper for not existing parameter' do
      host = FactoryBot.build(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      assert_nil @subject.host_param('not_existing_param')
    end

    test 'should render host param using "host_param" helper for not existing parameter using default value' do
      host = FactoryBot.build(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      assert_equal 42, @subject.host_param('not_existing_param', 42)
    end

    test 'should raise rendering exception if @host is not set while rendering @host based macros' do
      @subject.instance_variable_set('@host', nil)
      assert_raises(Foreman::Renderer::Errors::HostUnknown) do
        @subject.host_param('test')
      end
    end
  end

  describe '#host_param!' do
    test 'should raise rendering exception if host_param! is used for not existing param' do
      host = FactoryBot.build(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      assert_raises(Foreman::Renderer::Errors::HostParamUndefined) do
        @subject.host_param!('not_existing_param')
      end
    end
  end

  describe '#host_puppet_classes' do
    test 'should render puppetclasses using host_puppetclasses helper' do
      host = FactoryBot.build(:host, :with_puppetclass)
      @subject.instance_variable_set('@host', host)
      assert @subject.host_puppet_classes
    end
  end

  describe '#host_param_true?' do
    test 'should have host_param_true? helper' do
      host = FactoryBot.create(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      FactoryBot.create(:parameter, :name => 'true_param', :value => "true")
      assert @subject.host_param_true?('true_param')
    end
  end

  describe '#host_param_false?' do
    test 'should have host_param_false? helper' do
      host = FactoryBot.create(:host, :with_puppet)
      @subject.instance_variable_set('@host', host)
      FactoryBot.create(:parameter, :name => 'false_param', :value => "false")
      assert @subject.host_param_false?('false_param')
    end
  end
end
