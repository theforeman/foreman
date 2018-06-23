require 'test_helper'

class GraphqlAttributeTest < ActiveSupport::TestCase
  let(:resource_class) { Model }
  let(:graphql_attribute) { GraphqlAttribute.for(resource_class) }

  describe '#required?' do
    it 'detects than an attribute is required' do
      assert_equal true, graphql_attribute.required?(:name)
    end

    it 'detects than an attribute is optional' do
      assert_equal false, graphql_attribute.required?(:description)
    end
  end
end
