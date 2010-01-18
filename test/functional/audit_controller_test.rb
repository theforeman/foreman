require 'test_helper'

class AuditControllerTest < ActionController::TestCase
  

  def test_list
    get :list
    assert_response :success
  end

  def test_search
    get :search
    assert_response :success
  end

#  def test_edit
#    get :edit, :id => customers(:first_customer).id
#    assert_response :success
#  end

#  def test_show
#    get :show, :id => customers(:first_customer).id
#    assert_response :success
#  end

  def atest_customer_controller_CRUD

    # CREATE
    # Get the number of records
    record_no = Customer.count
    # Create a new record
    post  :create, {"commit"=>"Create", :record=>{"customer_code"=>"890"}}
    # Assert that the record is not nil
    assert_not_nil  assigns("record")
    # Look that the number of records has been increased by 1
    assert_equal  record_no+1, Customer.count

    # UPDATE
    # Get the number of records
    record_no = Customer.count
    # Update a record
    new_customer_code = "987"
    put :update, {"commit"=>"Update",:id=>customers(:first_customer).id,
                                      :record=>{"customer_code"=>new_customer_code}}
    # Assert that the record is not nil
    assert_not_nil  assigns("record")
    # Look that the number of records has stayed the same
    assert_equal  record_no, Customer.count
    # Check that the update took place
    customer = Customer.find(customers(:first_customer).id)
    assert_equal  new_customer_code, customer.customer_code

    # DELETE
    # Get the number of records
    record_no = Customer.count
    # Delete a record
    delete  :destroy, :id => customers(:first_customer).id
    # Look that the number of records has been decreased by 1
    assert_equal  record_no-1, Customer.count
  end

end
