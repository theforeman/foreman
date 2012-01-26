require 'test_helper'

class NoticesControllerTest < ActionController::TestCase
  def setup
    User.current = User.find_by_login "admin"
    @notice = Notice.create :global => false, :content => "hello", :level => "message"
    @request.env['HTTP_REFERER'] = hosts_path
  end

  def test_acknowledge_for_global
    @new_notice = Notice.create :global => true, :content => "hello", :level => "message"
    original = Notice.count
    delete :destroy, {:id => @new_notice.id}, set_session_user
    final = Notice.count
    assert original == final + 1
  end

  def test_acknowledge_for_individual
    if set_session_user[:user]
      user = User.find  set_session_user[:user]
    else
      user  = User.find_by_login("admin")
    end
    original = user.notices.count
    delete :destroy, {:id => @notice.id}, set_session_user
    final = user.notices.count
    assert (original == final + 1)
  end

  def test_notice_is_finally_deleted
    for user in User.all do
      delete :destroy, {:id => @notice.id}, set_session_user.merge(:user => user.id)
    end
    assert Notice.count == 0
  end
end
