require 'test_helper'

class NoticeTest < ActiveSupport::TestCase
  def test_should_be_valid
    User.as :admin do
      assert Notice.create(:global => true, :content => "hello", :level => "warning").valid?
    end
  end

  def test_should_attach_to_everyone
    notice = Notice.create(:global => false, :content => "hello", :level => "message")
    assert User.count == notice.users.count
  end

  def test_should_reject_incorrect_level
    assert Notice.create(:global => true, :content => "hello", :level => "bogus").invalid?
  end

end
