import $ from 'jquery';

export function trendTypeSelected({ value }) {
  $('#trend_trendable_id, #trend_name').attr('disabled', value !== 'FactName').val('');
}
