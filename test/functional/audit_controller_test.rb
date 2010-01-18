require 'test_helper'

class AuditControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:records)
  end

  test "should get show" do
    parameter = Parameter.new :name => "some_parameter", :value => "some_value"
    assert parameter.save!

    audited_record = Audit.find_by_auditable_id(parameter.id)
    assert_not_nil audited_record

    get :show, :id => audited_record.id
    assert_response :success
  end
end
