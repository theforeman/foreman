require 'test_helper'

class SelectableColumnsHelperTest < ActionView::TestCase
  include SelectableColumnsHelper

  let(:selected_columns) do
    [
      {
        key: 'key1', th: { label: 'Key1', width: '5%' },
                     td: { class: 'elipsis', callback: ->(o) { o.even? } }
      }.with_indifferent_access,
      { key: 'key2', th: { label: 'Key2', class: 'elipsis', width: '10%' },
                     td: { class: 'hidden', attr_callbacks: { title: ->(o) { o.to_s } }, callback: ->(o) { o.odd? } }
      }.with_indifferent_access,
    ]
  end

  setup do
    @selected_columns = selected_columns
  end

  test 'should render ths' do
    expected = [
      '<th width="5%">Key1</th>',
      '<th class="elipsis" width="10%">Key2</th>',
      '',
    ].join("\n").html_safe
    assert_equal expected, render_selected_column_ths
  end

  test 'should render tds' do
    expected = [
      '<td class="elipsis" >false</td>',
      '<td class="hidden" title="123">true</td>',
      '',
    ].join("\n").html_safe
    assert_equal expected, render_selected_column_tds(123)
  end
end
