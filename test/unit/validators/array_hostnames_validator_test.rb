require 'test_helper'

class ArrayHostnamesValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :hostnames, :array_hostnames => true
    attr_accessor :hostnames
  end

  setup do
    @item = Validatable.new
    @item.hostnames = ["localhost", "test-host.example.com"]
  end

  test "should pass when valid hostnames present" do
    assert @item.valid?
  end

  test "should fail when invalid hostname present" do
    @item.hostnames = ["invalid^.host", "valid.host"]
    refute @item.valid?
  end

  test "should fail when hostnames have invalid characters" do
    @item.hostnames = ["短期教室に.短に期"]
    refute @item.valid?
  end

  test "should pass when no hostnames present" do
    @item.hostnames = []
    assert @item.valid?
  end
end
