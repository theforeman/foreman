require 'test_helper'

class GenericResolverTest < ActiveSupport::TestCase
  test 'record resolver' do
    resolver = Resolvers::Generic.for(::Model).record

    assert_equal Resolvers::BaseResolver, resolver.superclass
    assert_includes resolver.ancestors, Resolvers::Concerns::Record
    assert_equal ::Model, resolver::MODEL_CLASS
  end

  test 'collection resolver' do
    resolver = Resolvers::Generic.for(::Model).collection

    assert_equal Resolvers::BaseResolver, resolver.superclass
    assert_includes resolver.ancestors, Resolvers::Concerns::Collection
    assert_equal ::Model, resolver::MODEL_CLASS
  end
end
