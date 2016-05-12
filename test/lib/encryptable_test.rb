require 'test_helper'

class EncryptableTest < ActiveSupport::TestCase
  setup do
    # default test behaviour should be no encryption
    ComputeResource.any_instance.stubs(:encryption_key).returns(nil)
  end

  def cr_with_encryption_key
    stub_encryption_key(FactoryGirl.build(:ec2_cr, password: 'encrypted-NEN1YVJtdWdaaTdlOHdiUXRHd29nWUZsOHc1UjdMb3p1MFZLenlLekFEbz0tLVA0MGVzUEorUDlJZHVUV2F6azUzUEE9PQ==--9f45d5c88ec582eeb48ebb906ae0a66345ded0fa'))
  end

  def stub_encryption_key(model)
    model.stubs(:encryption_key).returns('25d224dd383e92a7e0c82b8bf7c985e815f34cf5')
    model
  end

  test "encrypts?(:password) is true" do
    assert ComputeResource.encrypts?(:password)
  end

  test "encryptable_fields include?(:password)" do
    assert ComputeResource.encryptable_fields.include?(:password)
  end

  test "is_encryptable? is false when key is empty" do
    cr = FactoryGirl.build(:ec2_cr)
    cr.stubs(:encryption_key).returns(nil)
    cr.expects(:puts_and_logs)
    refute cr.is_encryptable?('foo')
  end

  test "is_decryptable? is false when key is empty" do
    cr = FactoryGirl.build(:ec2_cr)
    cr.stubs(:encryption_key).returns(nil)
    cr.expects(:puts_and_logs)
    refute cr.is_decryptable?('encrypted-WkQyR0xMVXZCT2hRTmVGaTNIWlY3RkoxM1M4')
  end

  test "this string IS encryptable and NOT decryptable" do
    str = "abcd1234"
    compute_resource = cr_with_encryption_key
    assert compute_resource.is_encryptable?(str)
    refute compute_resource.is_decryptable?(str)
  end

  test "this string is NOT encryptable and IS decryptable" do
    str = "encrypted-WkQyR0xMVXZCT2hRTmVGaTNIWlY3RkoxM1M4"
    compute_resource = cr_with_encryption_key
    refute compute_resource.is_encryptable?(str)
    assert compute_resource.is_decryptable?(str)
  end

  test "string is NOT encrypted AGAIN upon save if it is not changed" do
    compute_resource = cr_with_encryption_key
    orig_pass = compute_resource.password
    orig_pass_in_db = compute_resource.password_in_db
    refute compute_resource.is_decryptable?(orig_pass)
    assert compute_resource.is_decryptable?(orig_pass_in_db)
    assert compute_resource.save!
    compute_resource.reload
    new_pass = compute_resource.password
    new_pass_in_db = compute_resource.password_in_db
    assert_equal orig_pass, new_pass
    assert_equal orig_pass_in_db, new_pass_in_db
    assert compute_resource.is_decryptable?(new_pass_in_db)
  end

  test "string is re-encrypted upon save if password changed" do
    compute_resource = cr_with_encryption_key
    orig_pass = compute_resource.password
    orig_pass_in_db = compute_resource.password_in_db
    compute_resource.password = "3333333"
    assert compute_resource.save!
    compute_resource.reload
    new_pass = compute_resource.password
    new_pass_in_db = compute_resource.password_in_db
    refute_equal orig_pass, new_pass
    refute_equal orig_pass_in_db, new_pass_in_db
  end

  test "does not decrypt if string is not decryptable and returns database value" do
    compute_resource = stub_encryption_key(FactoryGirl.build(:compute_resource, password: '1234567'))
    orig_pass = compute_resource.password
    orig_pass_in_db = compute_resource.password_in_db
    refute compute_resource.is_decryptable?(orig_pass_in_db)
    refute compute_resource.is_decryptable?(orig_pass)
    assert_equal orig_pass, orig_pass_in_db
  end

  test "encrypt successfully" do
    compute_resource = cr_with_encryption_key
    plain_str = "secretpassword"
    encrypted_str = compute_resource.encrypt_field(plain_str)
    refute_equal plain_str, encrypted_str
    assert compute_resource.matches_prefix?(encrypted_str)
    assert compute_resource.is_decryptable?(encrypted_str)
  end

  test "decrypt successfully" do
    compute_resource = cr_with_encryption_key
    plain_str = "secretpassword"
    encrypted_str = compute_resource.encrypt_field(plain_str)
    decrypted_str = compute_resource.decrypt_field(encrypted_str)
    refute_equal encrypted_str, decrypted_str
    assert_equal plain_str, decrypted_str
  end

  test "encrypt_field returns nil if password is nil" do
    compute_resource = cr_with_encryption_key
    encrypted_str = compute_resource.encrypt_field(nil)
    assert_nil encrypted_str
  end
end
