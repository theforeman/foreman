/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-trigger */
/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-toggle */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-closest */
/* eslint-disable jquery/no-is */
/* eslint-disable func-names */

import $ from 'jquery';

import store from './react_app/redux';
import { actions as TemplateActions } from './react_app/components/TemplateGenerator';

export function initTypeChanges() {
  // update the hidden input which serves as template
  // and also all existing inputs in case of editing
  $('select.input_type_selector').each(function () {
    updateVisibilityAfterInputTypeChange($(this));
  });

  // every additional input that's added through "Add Input" button will also be handled
  $(document).on('change', 'select.input_type_selector', function () {
    updateVisibilityAfterInputTypeChange($(this));
  });
}

function updateVisibilityAfterInputTypeChange(select) {
  const fieldset = select.closest('fieldset');
  fieldset.find('div.custom_input_type_fields').hide();
  fieldset.find(`div.${select.val()}_input_type`).show();
}

export const toggleEmailFields = (checkbox) => {
  const $checkbox = $(checkbox);
  $checkbox
    .closest('form')
    .find('.email-fields')
    .toggle($checkbox.is(':checked'));
};

export const generateTemplate = (url, templateInputData) => {
  store.dispatch(TemplateActions.generateTemplate(url, templateInputData));
};

export const pollReportData = (url) => {
  store.dispatch(TemplateActions.pollReportData(url));
};

export const inputValueOnchange = (input) => {
  const searchValue = input.value === 'search';
  const resourceValue = input.value === 'resource';
  const plainValue = input.value === 'plain';
  const inputId = input.dataset.item;
  const $fields = $(input).closest('.fields');

  $fields
    .find(`.resource-type-${inputId}`)
    .toggle(searchValue || resourceValue);
  $fields.find(`.input-options-${inputId}`).toggle(plainValue);
  $fields.find(`.input-hidden-value-${inputId}`).toggle(plainValue);
};

export function snippetChanged(item) {
  const checked = $(item).is(':checked');

  $('#kind_selector').toggle(!checked);
  $('#snippet_message').toggle(checked);
  $('#association').toggle(!checked);
  if (checked) {
    $('#ptable_os_family').val('');
    $('#ptable_os_family').trigger('change');
  }
}
