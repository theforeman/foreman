require 'test_helper'

class CacertValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :cacert, :cacert => true
    attr_accessor :cacert
  end

  let(:validatable) { Validatable.new }
  let(:sample_cacert) { File.read(Rails.root.join('test/static_fixtures/certificates/example.com.crt')) }

  test 'should pass when cacert is valid' do
    validatable.cacert = sample_cacert
    assert validatable.valid?
  end

  test 'should pass when cacert uses CRLF line endings' do
    validatable.cacert = sample_cacert.gsub("\n", "\r\n")
    assert validatable.valid?
  end

  test 'should fail when cacert is invalid' do
    validatable.cacert = 'not a certificate'
    refute validatable.valid?
    assert_includes validatable.errors[:cacert], 'is not a valid CA certificate'
  end

  test 'should fail when cacert is malformed PEM' do
    validatable.cacert = "-----BEGIN CERTIFICATE-----\nYQo=\n-----END CERTIFICATE-----"
    refute validatable.valid?
    assert_includes validatable.errors[:cacert], 'is not a valid CA certificate'
  end

  test 'should allow blank' do
    assert validatable.valid?
    validatable.cacert = ''
    assert validatable.valid?
  end
end
