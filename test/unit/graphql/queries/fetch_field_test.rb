require 'test_helper'

class Queries::FetchFieldTest < ActiveSupport::TestCase
  test 'finds single record' do
    klass = 'SampleModelClass'
    type = 'SampleModelTypeClass'
    user = Object.new
    expected_record = Object.new
    ctx = { current_user: user }
    record_id = 1234
    model_query = stub('Queries::AuthorizedModelQuery')

    Queries::AuthorizedModelQuery.expects(:new)
                                 .with(model_class: klass, user: user)
                                 .returns(model_query)
    model_query.expects(:find_by).with(id: record_id).returns(expected_record)

    result = Queries::FetchField.new(type: type, model_class: klass)
                                .call(nil, { 'id' => record_id }, ctx)

    assert_equal expected_record, result
  end
end
