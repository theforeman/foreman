require 'test_helper'

class ScopesPerActionTest < ActiveSupport::TestCase
  include ScopesPerAction

  setup do
    self.class.send(:scopes_per_action).clear

    self.class.add_scope_for(:test_action) { |base_scope| base_scope.includes(:my_table1) }

    @scope = mock('scope')
    @scope_expectation = @scope.stubs(:includes).with(:my_table1)
  end

  test 'returns the same scope if callback returns nil' do
    actual = action_scope_for(:test_action, @scope)

    assert_equal @scope, actual
  end

  test 'can be called in chain' do
    new_scope = mock('new_scope')
    final_scope = mock('final_scope')
    @scope_expectation.returns(new_scope)
    new_scope.expects(:includes).with(:my_table2).returns(final_scope)

    self.class.add_scope_for(:test_action) { |base_scope| base_scope.includes(:my_table2) }

    actual = action_scope_for(:test_action, @scope)
    assert_equal final_scope, actual
  end
end
