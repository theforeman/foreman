require 'test_helper'

class ReportTemplateFormatTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  test ".all" do
    all_formats = ReportTemplateFormat.all
    assert_kind_of Array, all_formats
    assert_includes all_formats.map(&:id), :txt
  end

  test ".selectable" do
    selectable_formats = ReportTemplateFormat.selectable
    assert_kind_of Array, selectable_formats
    refute_includes selectable_formats.map(&:id), :txt
  end

  test ".all is superset of .selectable" do
    all_format_ids = ReportTemplateFormat.all.map(&:id)
    ReportTemplateFormat.selectable.each do |selectable|
      assert_includes all_format_ids, selectable.id, "All report templates does not include selectable format #{selectable.id}"
    end
  end

  test ".find" do
    found = ReportTemplateFormat.find(:csv)
    assert_equal :csv, found.id
    assert_nil ReportTemplateFormat.find(:some_that_does_not_exist)
  end

  test ".system" do
    system = ReportTemplateFormat.system
    assert_equal :txt, system.id
  end

  test ".default" do
    default = ReportTemplateFormat.default
    assert_equal :csv, default.id
  end

  test "#extension" do
    assert_equal 'txt', ReportTemplateFormat.find(:txt).extension
    assert_equal 'yaml', ReportTemplateFormat.find(:yaml).extension
    assert_equal 'csv', ReportTemplateFormat.find(:csv).extension
    assert_equal 'json', ReportTemplateFormat.find(:json).extension
    assert_equal 'html', ReportTemplateFormat.find(:html).extension
  end
end
