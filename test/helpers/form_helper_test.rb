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

  describe '#orderable_select_f' do
    it 'accepts array of choices' do
      choices_matcher = has_entry(options: all_of(includes(has_entries(label: 'one', value: 1)),
        includes(has_entries(label: 'two', value: 2))))
      expects(:react_form_input).with('orderableSelect', 'f', 'attr', has_entry(input_props: choices_matcher))
      orderable_select_f('f', 'attr', [['one', 1], ['two', 2]])
    end

    it 'accepts hash of choices' do
      choices_matcher = has_entry(options: all_of(includes(has_entries(label: 'one', value: 1)),
        includes(has_entries(label: 'two', value: 2))))
      expects(:react_form_input).with('orderableSelect', 'f', 'attr', has_entry(input_props: choices_matcher))
      orderable_select_f('f', 'attr', { 1 => 'one', 2 => 'two'})
    end
  end

  context '#blank_or_inherit_f attr is :pxe_loader' do
    context 'form object is hostgroup' do
      test "returns 'Inherit parent(<parent-pxe-loader-value>)'" do
        hostgroup = hostgroups(:inherited)
        f = ActionView::Helpers::FormBuilder.new(:hostgroup, hostgroup, nil, {})
        attr = :pxe_loader
        assert_equal "Inherit parent (#{hostgroup.parent.pxe_loader})", blank_or_inherit_f(f, attr)
      end

      test "inherited but pxe_loader attr is overriden -> returns 'Inherit parent(<parent-pxe-loader-value>)'" do
        new_pxe_loader = 'Grub UEFI'
        hostgroup = hostgroups(:inherited)
        hostgroup.pxe_loader = new_pxe_loader
        hostgroup.save
        f = ActionView::Helpers::FormBuilder.new(:hostgroup, hostgroup, nil, {})
        attr = :pxe_loader
        assert_equal "Inherit parent (#{new_pxe_loader})", blank_or_inherit_f(f, attr)
      end
    end

    context 'form object is host' do
      test "returns true" do
        hostgroup = hostgroups(:inherited)
        host = FactoryBot.build_stubbed(:host, :managed, hostgroup_id: hostgroup.id)
        f = ActionView::Helpers::FormBuilder.new(:host, host, nil, {})
        attr = :pxe_loader
        assert blank_or_inherit_f(f, attr)
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
    user = FactoryBot.build_stubbed(:user,
      :organizations => [taxonomies(:organization1)])
    form_for Filter.new do |f|
      assert_match(/input name=\"filter\[organization_ids\]\[\].*/,
        multiple_checkboxes(f, :organizations, f.object, user.organizations))
    end
  end
end
