/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-attr */

import $ from 'jquery';

export function trendTypeSelected({ value }) {
  $('#trend_trendable_id, #trend_name')
    .attr('disabled', value !== 'FactName')
    .val('');
}
