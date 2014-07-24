require 'test_helper'

class AuthorizeAssociationsValidatorTest < ActiveSupport::TestCase

  def setup
    @validatable = Validatable.new
  end

  test "valid if all associations aren't authorized" do
    assert @validatable.valid?
    assert_empty @validatable.errors[:belongs_to_class]
    assert_empty @validatable.errors[:has_many_class]
  end

  test "invalid if belongs_to association isn't authorized" do
    @validatable.belongs_to = false

    assert @validatable.invalid?
    refute_empty @validatable.errors[:belongs_to_class]
  end

  test "invalid if has_many association isn't authorized" do
    @validatable.has_many = false

    assert @validatable.invalid?
    refute_empty @validatable.errors[:has_many_class]
  end

  test "invalid if has_many and belongs_to associations aren't authorized" do
    assert @validatable.valid?

    @validatable.has_many = false
    @validatable.belongs_to = false

    assert @validatable.invalid?
    refute_empty @validatable.errors[:belongs_to_class]
    refute_empty @validatable.errors[:has_many_class]
  end

  test "valid if associations haven't changed" do
    assert @validatable.valid?

    @validatable.has_many = false
    @validatable.belongs_to = false
    @validatable.has_many_changed = false
    @validatable.belongs_to_changed = false

    assert @validatable.valid?
    assert_empty @validatable.errors[:belongs_to_class]
    assert_empty @validatable.errors[:has_many_class]
  end

end

class Association

  @@collection = []

  attr_accessor :authorized, :id

  def initialize(authorized)
    @authorized = authorized
    @@collection << self if authorized
  end

  def authorized?(permission)
    @authorized
  end

  def self.authorized(permission)
    @@collection
  end

end

class Reflection

  attr_accessor :name, :macro

  def initialize(name, macro)
    @name = name
    @macro = macro
  end

  def klass
    Association
  end

end

class Validatable
  include ActiveModel::Validations
  validates_with AuthorizeAssociationsValidator

  attr_accessor :has_many, :belongs_to, :has_many_changed, :belongs_to_changed

  def initialize(belongs_to = true, has_many = true)
    @has_many = has_many
    @belongs_to = belongs_to
    self.errors[:belongs_to_class] = []
    self.errors[:has_many_class] = []
  end

  def self.reflect_on_association(association)
    Reflection.new(association, association.to_s.split('_class')[0])
  end

  def self.reflect_on_all_associations
    [
      Reflection.new(:belongs_to_class, :belongs_to),
      Reflection.new(:has_many_class, :has_many)
    ]
  end

  def association_authorizations
    {
      :belongs_to_class   => :view_belongs_to,
      :has_many_class     => :view_has_many,
    }
  end

  def belongs_to_class
    Association.new(@belongs_to)
  end

  def has_many_class
    [Association.new(@has_many), Association.new(@has_many)]
  end

  def has_many_class_changed?
    @has_many_changed
  end

  def belongs_to_class_changed?
    @belongs_to_changed
  end

end
