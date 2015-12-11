require 'test_helper'

class UrlValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :url, url: {schemes: ['http', 'https', 'nfs', 'ftp']}
    attr_accessor :url
  end

  setup do
    @validatable = Validatable.new
  end

  test 'url regexp does not match new lines' do
    @validatable.url = "http://puppet.example.com:4568\njavascript('alert')"
    refute_valid @validatable
  end

  test 'passes if url uses one of the specified schemes' do
    @validatable.url = 'ftp://puppet.example.com:4568'
    assert_valid @validatable
  end

  test 'fails if url contains the wrong schemes' do
    @validatable.url = 'unix://puppet.example.com:4568'
    refute_valid @validatable
    assert_match /URL must be valid/, @validatable.errors.messages.to_s
  end

  test 'fails if the url lacks a path' do
    @validatable.url = 'https://'
    refute_valid @validatable
    assert_match /URL must be valid/, @validatable.errors.messages.to_s
  end

  test 'fails if the url only has a protocol' do
    @validatable.url = 'https:'
    refute_valid @validatable
    assert_match /URL must be valid/, @validatable.errors.messages.to_s
  end

  test 'passes if the url has a username/password' do
    @validatable.url = 'http://user:password@foo.example.com/bar'
    assert_valid @validatable
  end
end
