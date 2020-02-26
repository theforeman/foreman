require 'test_helper'

class BaseScopeTest < ActiveSupport::TestCase
  let(:described_class) { ::Foreman::Renderer::Scope::Base }

  describe 'inheritance' do
    let(:parent_class) { Class.new(described_class).tap { |c| c.include(Foreman::Renderer::Scope::Variables::Base) } }
    let(:child_class) { Class.new(parent_class) }

    test 'child class should inherit loaders' do
      assert_not_empty parent_class.loaders
      assert_same_elements parent_class.loaders, child_class.loaders
    end
  end
end
