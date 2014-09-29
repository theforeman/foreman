require 'test_helper'

class OrganizationAssociationValidatorTest < ActiveSupport::TestCase

  def setup
    @validatable = Validatable.new
  end

  test "valid if all associations belong to the same Organization" do
    assert @validatable.valid?
    assert_empty @validatable.errors[:base]
  end

  test "invalid if any associations belong to another Organization" do
    @validatable.organization = Organization.new(:name => 'test_name')

    assert @validatable.invalid?
    refute_empty @validatable.errors[:base]
  end

end

class Validatable
  include ActiveModel::Validations
  validates_with OrganizationAssociationValidator

  attr_accessor :organization

  def initialize
    @organization = Organization.new(:name => "validatable")
    @@reflections = [Reflection.new(:test, @organization), Reflection.new(:organization, @organization)]
  end

  def self.reflect_on_association(association)
    @@reflections.find { |reflect| reflect.name == association }
  end

  def self.reflect_on_all_associations
    @@reflections
  end

  def test
    self.class.reflect_on_association(:test)
  end

end

class Reflection < Validatable

  attr_accessor :name, :id

  def initialize(name, organization)
    @name = name
    @id = name
    @organization = organization
  end

end
