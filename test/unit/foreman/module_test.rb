require 'test_helper'

class Foreman::ModuleTest < ActiveSupport::TestCase
  module Testmodule; end
  describe '#resolve' do
    it 'resolves a String to a module' do
      assert_equal Testmodule, Foreman::Module.resolve('Foreman::ModuleTest::Testmodule')
    end

    it 'resolves a Proc to a module' do
      assert_equal Testmodule, Foreman::Module.resolve(-> { Foreman::ModuleTest::Testmodule })
    end

    it 'passes through a module' do
      assert_equal Testmodule, Foreman::Module.resolve(Testmodule)
    end
  end
end
