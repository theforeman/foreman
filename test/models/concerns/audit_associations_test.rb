require 'test_helper'

class AuditAssociationsTest < ActiveSupport::TestCase
  test ":find_association_class should be give a class_name" do
    user_obj = User.new
    role_class = user_obj.send('find_association_class', 'roles')
    assert_equal Role, role_class
  end
end
