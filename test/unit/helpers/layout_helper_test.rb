require 'test_helper'

class LayoutHelperTest < ActionView::TestCase
  include LayoutHelper
  test "alert should be closable" do
    result = alert(:close => true)
    assert_include result, 'alert-dismissable'
    assert_include result, alert_close
  end

  test "alert should not be closeable" do
    result = alert(:close => false)
    assert_not_include result, 'alert-dismissable'
    assert_not_include result, alert_close
  end

  test "is_required?(f, attr) method returns true if attribute is required and false if not required" do
    f = ActionView::Helpers::FormBuilder.new(:hostgroup, Hostgroup.new, @hostgroup, {})
    assert is_required?(f, :name)
    assert is_required?(f, :title)
    refute is_required?(f, :environment_id)
    refute is_required?(f, :parent_id)
    f = ActionView::Helpers::FormBuilder.new(:host, Host::Managed.new, @host, {})
    refute is_required?(f, :architecture_id) # not required because of :if
    refute is_required?(f, :mac)             # not required because of :unless
  end

  test "table css classes should return the regular classes for table" do
    assert_equal table_css_classes,"table table-bordered table-striped table-condensed "
  end

  test "table css classes should return the regular classes for table plus the added classes" do
    assert_equal table_css_classes("test-class"),"table table-bordered table-striped table-condensed test-class"
  end

  context '#select_f' do
    test 'include_blank works with #to_s as retreival method' do
      form_for User.new do |f|
        fields_for :user_mail_notifications do |notifications|
          values = ['one', :two]
          html = select_f(notifications, :interval, values, :to_s, :to_sym, { :include_blank => _('No emails') }, {})
          assert_match /one/, html
          assert_no_match /to_s/, html
        end
      end
    end
  end

  context '#field' do
    test 'uses custom errors' do
      user = User.new
      user.mail = 'aaaa'
      user.valid?
      form_for User.new do |f|
        html = field(f, :login, :error => user.errors[:mail]) do
          'zzz'
        end
        assert_match /is invalid/, html
      end
    end

    test 'uses object errors, if no custom errors defined' do
      user = User.new
      user.mail = 'aaaa'
      user.valid?
      form_for user do |f|
        html = field(f, :login) do
          'zzz'
        end
        assert_match /blank/, html
      end
    end
  end
end
