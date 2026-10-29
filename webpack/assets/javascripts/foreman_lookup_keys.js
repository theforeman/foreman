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

// Delegate so build_match's form submit handler runs before serialization.
export const serializeLookupValues = event => {
  const form = event.target;
  if (!form.matches('form[data-lookup-values-json="true"]')) return;
  form.querySelectorAll('.lookup_values_json').forEach(jsonField => {
    const container = jsonField.closest('.children_fields.lookup_values');
    if (!container) return;

    const values = Array.from(container.querySelectorAll('tr.matchers'))
      .filter(row => !row.closest('.lookup_values_fields_template'))
      .map(row => {
        const read = key => row.querySelector(`[name$="[${key}]"]`);
        const value = {
          match: read('match').value,
          omit: Boolean(
            row.querySelector('input[type="checkbox"][name$="[omit]"]:checked')
          ),
        };
        // Omitted values were disabled controls before JSON transport. Do not
        // reassign their displayed string, since omitted values skip casting.
        // Read non-omitted values even on a repeated submit after we disabled them.
        if (!value.omit) value.value = read('value').value;
        ['id', '_destroy'].forEach(key => {
          const input = read(key);
          if (input) value[key] = input.value;
        });
        return value;
      });

    jsonField.value = JSON.stringify(values);
    container
      .querySelectorAll('[name*="[lookup_values_attributes]"]')
      .forEach(input => {
        input.disabled = true;
      });
  });
};

$(document).on(
  'submit',
  'form[data-lookup-values-json="true"]',
  serializeLookupValues
);
