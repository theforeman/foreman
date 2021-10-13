/* eslint-disable jquery/no-toggle */
/* eslint-disable jquery/no-each */
/* eslint-disable func-names */

import $ from 'jquery';

export function initAdvancedFields() {
  $('a.advanced_fields_switch').each(function () {
    const field = $(this);
    field.on('click', updateAdvancedFields);
  });
}

function updateAdvancedFields() {
  const switcher = $('a.advanced_fields_switch');
  const original = switcher.html();
  switcher.html(switcher.data('alternativeLabel'));
  switcher.data('alternativeLabel', original);

  switcher
    .siblings('i.fa')
    .toggleClass('fa-angle-right')
    .toggleClass('fa-angle-down');

  $('div.advanced').toggle();
}
