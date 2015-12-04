require 'test_helper'

class UrlSchemaValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :url, :url_schema => ['http', 'https', 'nfs', 'ftp']
    attr_accessor :url
  end

  setup do
    @validatable = Validatable.new
  end

  test 'url regexp does not match new lines' do
    @validatable.url = "http://puppet.example.com:4568\njavascript('alert')"
    refute_valid @validatable
  end

  test 'passes if url uses one of the specified schemas' do
    @validatable.url = 'ftp://puppet.example.com:4568'
    assert_valid @validatable
  end

  test 'fails if url contains the wrong schema' do
    @validatable.url = 'unix://puppet.example.com:4568'
    refute_valid @validatable
    assert_match /URL must be valid/, @validatable.errors.messages.to_s
  end
end
