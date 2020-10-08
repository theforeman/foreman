require 'test_helper'

class TranspilersTest < ActiveSupport::TestCase
  setup do
    host = FactoryBot.build_stubbed(:host)
    template = OpenStruct.new(
      name: 'Test',
      template: 'Test'
    )
    source = Foreman::Renderer::Source::Database.new(
      template
    )
    @scope = Class.new(Foreman::Renderer::Scope::Base) do
      include Foreman::Renderer::Scope::Macros::Transpilers
    end.send(:new, host: host, source: source)
    @success = mock()
    @success.stubs(:success?).returns(true)
  end

  describe '#transpile_coreos_linux_config' do
    test 'should call the transpiler' do
      Foreman::CommandRunner.any_instance.expects(:capture3).with(Setting[:ct_command], "IGNORE")
        .returns(["JSON", "", @success])

      assert_equal "JSON", @scope.transpile_coreos_linux_config("IGNORE")
    end
  end

  describe '#transpile_fedora_coreos_config' do
    test 'should call the transpiler' do
      Foreman::CommandRunner.any_instance.expects(:capture3).with(Setting[:fcct_command], "IGNORE")
        .returns(["JSON", "", @success])

      assert_equal "JSON", @scope.transpile_fedora_coreos_config("IGNORE")
    end
  end
end
