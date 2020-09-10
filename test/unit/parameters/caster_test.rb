require 'test_helper'

class CasterTest < ActiveSupport::TestCase
  context "Casting to different stuff (successfully)" do
    test "string" do
      item = OpenStruct.new(:foo => :bar)
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo).cast!
      assert_equal item.foo, "bar"
    end

    test "integer" do
      # this also tests that "132" isn't octal
      item = OpenStruct.new(:foo => "132")
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :integer).cast!
      assert_equal item.foo, 132
    end

    test "hex int" do
      item = OpenStruct.new(:foo => "0xabba")
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :integer).cast!
      assert_equal item.foo, 43962
    end

    test "octal int" do
      item = OpenStruct.new(:foo => "012")
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :integer).cast!
      assert_equal item.foo, 10
    end

    test "the truth" do
      item = OpenStruct.new(:foo => "true")
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :boolean).cast!
      assert_equal item.foo, true
    end

    test "the lies" do
      item = OpenStruct.new(:foo => "false")
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :boolean).cast!
      assert_equal item.foo, false
    end

    test "boolean is casted correctly when changing value from true to false" do
      item = OpenStruct.new(:foo => "true")
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :boolean, :value => false).cast!
      assert_equal false, item.foo
    end

    test "empty boolean is not casted to false" do
      item = OpenStruct.new(:foo => "true")
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :boolean, :value => "").cast!
      assert_nil item.foo
    end

    test "array (json)" do
      item = OpenStruct.new(:foo => [1, 2, 3].to_json)
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :array).cast!
      assert_equal item.foo, [1, 2, 3]
    end

    test "array (yml)" do
      item = OpenStruct.new(:foo => [1, 2, 3].to_yaml)
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :array).cast!
      assert_equal item.foo, [1, 2, 3]
    end

    test "hash (json)" do
      item = OpenStruct.new(:foo => {:a => :b}.to_json)
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :hash).cast!
      assert_equal item.foo, {"a" => "b"}
    end

    test "hash (yml)" do
      item = OpenStruct.new(:foo => {:a => :b}.to_yaml)
      Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :hash).cast!
      assert_equal item.foo, {:a => :b}
    end
  end

  context "failures" do
    test "caster raises TypeError" do
      item = OpenStruct.new(:foo => "blah")
      assert_raises(TypeError) do
        Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :zibi).cast!
      end
    end

    test "caster raises error on invalid hash" do
      item = OpenStruct.new(:foo => "{:foo => :bar}")
      assert_raises(JSON::ParserError) do
        Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :hash).cast!
      end
    end

    test "caster raises TypeError on invalid real" do
      item = OpenStruct.new(:foo => "blah")
      assert_raises(TypeError) do
        Foreman::Parameters::Caster.new(item, :attribute_name => :foo, :to => :real).cast!
      end
    end
  end
end
