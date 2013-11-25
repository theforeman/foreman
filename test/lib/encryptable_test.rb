require 'test_helper'

class EncryptableTest < ActiveSupport::TestCase

  # use ComputeResource as class to test Encryptable module
  # class ComputeResource < ActiveRecord::Base
  #   include Encryptable
  #   encrypts :password
  # end
  def setup
    User.current = users(:admin)
  end

  test "encrypts?(:password) is true" do
    assert ComputeResource.encrypts?(:password)
  end

  test "encryptable_fields include?(:password)" do
    assert ComputeResource.encryptable_fields.include?(:password)
  end

  test "this string IS encryptable and NOT decryptable" do
    str = "abcd1234"
    compute_resource = compute_resources(:one)
    assert compute_resource.is_encryptable?(str)
    refute compute_resource.is_decryptable?(str)
  end

  test "this string is NOT encryptable and IS decryptable" do
    str = "encrypted-WkQyR0xMVXZCT2hRTmVGaTNIWlY3RkoxM1M4"
    compute_resource = compute_resources(:one)
    refute compute_resource.is_encryptable?(str)
    assert compute_resource.is_decryptable?(str)
  end

  test "string is NOT encrypted AGAIN upon save if it is not changed" do
    compute_resource = compute_resources(:one)
    orig_pass = compute_resource.password
    orig_pass_in_db = compute_resource.password_in_db
    refute compute_resource.is_decryptable?(orig_pass)
    assert compute_resource.is_decryptable?(orig_pass_in_db)
    assert compute_resource.save
    compute_resource.reload
    new_pass = compute_resource.password
    new_pass_in_db = compute_resource.password_in_db
    assert_equal orig_pass, new_pass
    assert_equal orig_pass_in_db, new_pass_in_db
    assert compute_resource.is_decryptable?(new_pass_in_db)
  end

  test "string is re-encrypted upon save if password changed" do
    # :one fixture password is saved encrypted
    compute_resource = compute_resources(:one)
    orig_pass = compute_resource.password
    orig_pass_in_db = compute_resource.password_in_db
    compute_resource.password = "3333333"
    assert compute_resource.save
    compute_resource.reload
    new_pass = compute_resource.password
    new_pass_in_db = compute_resource.password_in_db
    refute_equal orig_pass, new_pass
    refute_equal orig_pass_in_db, new_pass_in_db
  end

  test "does not decrypt if string is not decryptable and returns database value" do
    # :yourcompute fixture password is not saved encrypted (1234567)
    compute_resource = compute_resources(:yourcompute)
    orig_pass = compute_resource.password
    orig_pass_in_db = compute_resource.password_in_db
    refute compute_resource.is_decryptable?(orig_pass_in_db)
    refute compute_resource.is_decryptable?(orig_pass)
    assert_equal orig_pass, orig_pass_in_db
  end

  test "encrypt successfully" do
    compute_resource = ComputeResource.new
    plain_str = "secretpassword"
    encrypted_str = compute_resource.encrypt_field(plain_str)
    refute_equal plain_str, encrypted_str
    assert compute_resource.matches_prefix?(encrypted_str)
    assert compute_resource.is_decryptable?(encrypted_str)
  end

  test "decrypt successfully" do
    compute_resource = ComputeResource.new
    plain_str = "secretpassword"
    encrypted_str = compute_resource.encrypt_field(plain_str)
    decrypted_str = compute_resource.decrypt_field(encrypted_str)
    refute_equal encrypted_str, decrypted_str
    assert_equal plain_str, decrypted_str
  end

  test "returns blank string '' if password is nil" do
    compute_resource = ComputeResource.new
    encrypted_str = compute_resource.encrypt_field(nil)
    assert encrypted_str == ''
  end

end

