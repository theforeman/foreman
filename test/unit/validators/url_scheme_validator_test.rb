require 'test_helper'

class URLSchemeValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :url, :url_scheme => { in: ['http', 'https', 'nfs', 'ftp'] }
    attr_accessor :url
  end

  class ValidatableWithBlank
    include ActiveModel::Validations
    validates :url, :url_scheme => { in: ['http', 'https'], allow_blank: true }
    attr_accessor :url
  end

  setup do
    @validatable = Validatable.new
    @blank_validatable = ValidatableWithBlank.new
  end

  test 'accepts valid HTTP URL' do
    @validatable.url = 'http://example.com'
    assert_valid @validatable
  end

  test 'accepts valid HTTPS URL' do
    @validatable.url = 'https://example.com/path'
    assert_valid @validatable
  end

  test 'accepts valid FTP URL' do
    @validatable.url = 'ftp://files.example.com/pub'
    assert_valid @validatable
  end

  test 'accepts valid NFS URL' do
    @validatable.url = 'nfs://server/exports/path'
    assert_valid @validatable
  end

  test 'accepts URL with port' do
    @validatable.url = 'http://puppet.example.com:4568'
    assert_valid @validatable
  end

  test 'accepts URL with path and query' do
    @validatable.url = 'https://example.com/path?key=value'
    assert_valid @validatable
  end

  test 'rejects URL with wrong scheme' do
    @validatable.url = 'unix://puppet.example.com:4568'
    refute_valid @validatable
    assert_match /URL must be valid/, @validatable.errors.messages.to_s
  end

  test 'rejects URL without host' do
    @validatable.url = 'https://'
    refute_valid @validatable
  end

  test 'rejects URL with newline injection' do
    @validatable.url = "http://puppet.example.com:4568\njavascript:alert(1)"
    refute_valid @validatable
  end

  test 'rejects empty string' do
    @validatable.url = ''
    refute_valid @validatable
  end

  test 'rejects nil' do
    @validatable.url = nil
    refute_valid @validatable
  end

  test 'rejects plain text' do
    @validatable.url = 'not a url at all'
    refute_valid @validatable
  end

  test 'rejects URL with spaces' do
    @validatable.url = 'http://example .com'
    refute_valid @validatable
  end

  test 'allow_blank accepts empty string' do
    @blank_validatable.url = ''
    assert_valid @blank_validatable
  end

  test 'allow_blank accepts nil' do
    @blank_validatable.url = nil
    assert_valid @blank_validatable
  end

  test 'allow_blank still validates non-blank values' do
    @blank_validatable.url = 'not-a-url'
    refute_valid @blank_validatable
  end

  test 'allow_blank accepts valid URL' do
    @blank_validatable.url = 'https://proxy.example.com:8080'
    assert_valid @blank_validatable
  end

  test 'URLSchemaValidator alias exists for backward compatibility' do
    assert_equal URLSchemeValidator, URLSchemaValidator
  end
end
