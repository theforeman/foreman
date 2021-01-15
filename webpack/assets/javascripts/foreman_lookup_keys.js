/* eslint-disable jquery/no-data */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-class */
/* eslint-disable jquery/no-closest */
/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-sizzle */
/* eslint-disable jquery/no-text */

import $ from 'jquery';

const matcherFieldChanged = (element, currentValue) => {
  const { initialValue } = $(element).data();

  const popover = $(element)
    .closest('td')
    .find('a.warn-field-changed');

  if (initialValue === currentValue) {
    $(element).removeClass('matcher-field-changed');
    $(popover).removeClass('warn-show');
  } else {
    $(element).addClass('matcher-field-changed');
    $(popover).addClass('warn-show');
  }
};

export const matcherKeyChanged = element => {
  const currentValue = $(element)
    .find(':selected')
    .text();

  matcherFieldChanged(element, currentValue);
};

export const matcherValueChanged = element => {
  const currentValue = $(element).val();

  matcherFieldChanged(element, currentValue);
};
