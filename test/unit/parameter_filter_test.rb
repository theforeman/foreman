require 'test_helper'

class ParameterFilterTest < ActiveSupport::TestCase
  let(:klass) do
    mock('Example').tap do |k|
      k.stubs(:name).returns('Example')
    end
  end
  let(:filter) { Foreman::ParameterFilter.new(klass) }
  let(:ui_context) { Foreman::ParameterFilter::Context.new(:ui, 'examples', 'create') }

  test "permitting second-level attributes via permit(Symbol)" do
    filter.permit(:test)
    assert_equal({'test' => 'a'}, filter.filter_params(params(:example => {:test => 'a', :denied => 'b'}), ui_context).to_h)
  end

  test "permitting second-level attributes via block" do
    filter.permit { |ctx| ctx.permit(:test) }
    assert_equal({'test' => 'a'}, filter.filter_params(params(:example => {:test => 'a', :denied => 'b'}), ui_context).to_h)
  end

  test "block contains controller/action names" do
    filter.permit do |ctx|
      ctx.controller_name == 'examples' || raise('controller is not "examples"')
      ctx.action == 'create' || raise('action is not "create"')
    end
    filter.filter_params(params(:example => {:test => 'a'}), ui_context)
  end

  test "permitting second-level arrays via permit(Symbol => Array)" do
    filter.permit(:test => [])
    assert_equal({}, filter.filter_params(params(:example => {:test => 'a'}), ui_context).to_h)
    assert_equal({'test' => ['a']}, filter.filter_params(params(:example => {:test => ['a']}), ui_context).to_h)
  end

  test "permitting third-level attributes via permit(Symbol => Array[Symbol])" do
    filter.permit(:test => [:inner])
    assert_equal({'test' => {'inner' => 'a'}}, filter.filter_params(params(:example => {:test => {:inner => 'a', :denied => 'b'}}), ui_context).to_h)
  end

  test "constructs permit() args for second-level attribute" do
    filter.permit(:test)
    assert_equal [:test], filter.filter(ui_context)
  end

  test "blocks second-level attributes for UI when :ui => false" do
    filter.permit_by_context(:test, :ui => false)
    assert_equal({}, filter.filter_params(params(:example => {:test => 'a'}), ui_context).to_h)
  end

  test "#permit_by_context raises error for unknown context types" do
    assert_raises(ArgumentError) { filter.permit_by_context(:test, :example => false) }
  end

  test "#accessible_attributes returns list of known attributes" do
    filter.permit(:test, :hash => [:inner])
    assert_equal ['test', 'hash'], filter.accessible_attributes(ui_context)
  end

  context "with nested object" do
    let(:klass2) do
      mock('Example').tap do |k|
        k.stubs(:name).returns('Example')
      end
    end
    let(:filter2) { Foreman::ParameterFilter.new(klass2) }

    test "constructs permit() args for nested attribute through second filter" do
      filter2.permit_by_context(:inner, :nested => true)
      filter2.permit(:ui_only)
      filter.permit(:test, :nested => [filter2])
      assert_equal [:test, {:nested => [[:inner]]}], filter.filter(ui_context)
    end

    test "permits nested attribute through second filter" do
      filter2.permit_by_context(:inner, :nested => true)
      filter2.permit(:ui_only)
      filter.permit(:test, :nested => [filter2])
      assert_equal({'test' => 'a', 'nested' => [{'inner' => 'b'}]}, filter.filter_params(params(:example => {:test => 'a', :nested => [{:inner => 'b', :ui_only => 'b'}]}), ui_context).to_h)
      assert_equal({'test' => 'a', 'nested' => {'123' => {'inner' => 'b'}}}, filter.filter_params(params(:example => {:test => 'a', :nested => {'123' => {:inner => 'b', :ui_only => 'b'}}}), ui_context).to_h)
    end

    test "second filter block has access to original controller/action" do
      filter2.permit do |ctx|
        ctx.controller_name == 'examples' || raise('controller is not "examples"')
        ctx.action == 'create' || raise('action is not "create"')
      end
      filter.permit(:test, :nested => [filter2])
      filter.filter_params(params(:example => {:test => 'a', :nested => [{:inner => 'b'}]}), ui_context)
    end
  end

  context "with plugin registered filters" do
    test "permits plugin-added attribute" do
      plugin = mock('plugin')
      plugin.expects(:parameter_filters).with(klass).returns([[:plugin_ext, :another]])
      Foreman::Plugin.expects(:all).returns([plugin])
      assert_equal({'plugin_ext' => 'b'}, filter.filter_params(params(:example => {:test => 'a', :plugin_ext => 'b'}), ui_context).to_h)
    end

    test "permits plugin-added attributes from blocks" do
      plugin = mock('plugin')
      rule = [proc { |ctx| ctx.permit(:plugin_ext) }]
      plugin.expects(:parameter_filters).with(klass).returns([rule])
      Foreman::Plugin.expects(:all).returns([plugin])
      assert_equal({'plugin_ext' => 'b'}, filter.filter_params(params(:example => {:test => 'a', :plugin_ext => 'b'}), ui_context).to_h)
      refute_empty(rule)
    end
  end

  context "with top_level_hash" do
    test "applies filters without top-level hash" do
      filter.permit(:test)
      assert_equal({'test' => 'a'}, filter.filter_params(params(:changed => {:test => 'a', :denied => 'b'}), ui_context, :changed).to_h)
    end
  end

  context "with top_level_hash => :none" do
    test "applies filters without top-level hash" do
      filter.permit(:test)
      assert_equal({'test' => 'a'}, filter.filter_params(params(:test => 'a', :denied => 'b'), ui_context, :none).to_h)
    end
  end

  private

  def params(p)
    ActionController::Parameters.new(p)
  end
end
