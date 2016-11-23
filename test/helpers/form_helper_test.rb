require 'test_helper'

class FormHelperTest < ActionView::TestCase
  include FormHelper
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

  test "is_required?(f, attr) method returns true if attribute is required and false if not required" do
    f = ActionView::Helpers::FormBuilder.new(:hostgroup, Hostgroup.new, @hostgroup, {})
    assert is_required?(f, :name)
    refute is_required?(f, :environment_id)
    refute is_required?(f, :parent_id)
    f = ActionView::Helpers::FormBuilder.new(:host, Host::Managed.new, @host, {})
    refute is_required?(f, :architecture_id) # not required because of :if
    refute is_required?(f, :mac)             # not required because of :unless
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

  test 'multiple_checkboxes produces right output for taxonomy relations' do
    user = FactoryGirl.build(:user,
                             :organizations => [taxonomies(:organization1)])
    form_for Filter.new do |f|
      assert_match(/input name=\"filter\[organization_ids\]\[\].*/,
        multiple_checkboxes(f, :organizations, f.object, user.organizations))
    end
  end
end
