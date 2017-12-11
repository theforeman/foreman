require 'test_helper'

class ActionsBuilderTest < ActiveSupport::TestCase
  def setup
    @builder = UINotifications::ActionsBuilder.new
  end

  test 'multiple actions can be pushed in chain' do
    @builder.push('a', 'b', true).push('c','d',false)
    assert_equal 2, @builder.instance_variable_get('@actions').size
  end

  test 'actions are built in desired format' do
    result = @builder.push('a', 'b', true).push('c','d',false).build
    expected = {
      :links => [
        { :href => 'a', :title => 'b', :external => true },
        { :href => 'c', :title => 'd', :external => false }
      ]
    }
    assert_equal expected, result
  end
end
