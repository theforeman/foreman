require 'test_helper'

class AuthorizableTest < ActiveSupport::TestCase

  def setup
    ::User.current = users(:admin)
  end

  test "classes including Authorizable should be invalid if user does not belong to the organization" do
    authorizables = ActiveRecord::Base.send(:subclasses).select { |klass| klass.ancestors.include?(Authorizable) }

    authorizables.each do |authorizable_class|
      @authorizable = authorizable_class.new

      if @authorizable.respond_to?(:organizations)
        @authorizable.organizations << taxonomies(:organization1)

        ::User.current = users(:restricted)
        @authorizable.valid?
        refute_empty @authorizable.errors[:organizations]

        ::User.current.organizations << taxonomies(:organization1)
        @authorizable.valid?
        assert_empty @authorizable.errors[:organizations]

        ::User.current.organizations = []
      end
    end
  end

  test "classes including Authorizable should be invalid if user does not belong to the location" do
    authorizables = ActiveRecord::Base.send(:subclasses).select { |klass| klass.ancestors.include?(Authorizable) }

    authorizables.each do |authorizable_class|
      @authorizable = authorizable_class.new

      if @authorizable.respond_to?(:locations)
        @authorizable.locations << taxonomies(:location1)

        ::User.current = users(:restricted)
        @authorizable.valid?
        refute_empty @authorizable.errors[:locations]

        ::User.current.locations << taxonomies(:location1)
        @authorizable.valid?
        assert_empty @authorizable.errors[:locations]

        ::User.current.locations = []
      end
    end
  end

end
