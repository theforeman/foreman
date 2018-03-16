require 'test_helper'

class Queries::PluralFieldTest < ActiveSupport::TestCase
  test 'fetch results' do
    klass = 'SampleModelClass'
    type = 'SampleModelTypeClass'
    user = Object.new
    expected_results = Object.new
    args = {
      'search' => 'search_argument',
      'order' => 'desc',
      'name' => 'sample_name'
    }
    expected_args = args.slice('search', 'order').symbolize_keys
    ctx = { current_user: user }
    model_query = stub('Queries::AuthorizedModelQuery')

    Queries::AuthorizedModelQuery.expects(:new)
                                 .with(model_class: klass, user: user)
                                 .returns(model_query)
    model_query.expects(:results).with(expected_args).returns(expected_results)

    result = Queries::PluralField.new(type: type, model_class: klass)
                                 .call(nil, args, ctx)

    assert_equal expected_results, result
  end
end
