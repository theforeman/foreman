/* eslint-disable func-names */
import $ from 'jquery';

import store from './react_app/redux';
import { actions as TemplateActions } from './react_app/components/TemplateGenerator';

export function initTypeChanges() {
  // update the hidden input which serves as template
  // and also all existing inputs in case of editing
  $('select.input_type_selector').each(function() {
    updateVisibilityAfterInputTypeChange($(this));
  });

  // every additional input that's added through "Add Input" button will also be handled
  $(document).on('change', 'select.input_type_selector', function() {
    updateVisibilityAfterInputTypeChange($(this));
  });
}

export function initScheduleFormSubmit(scheduleUrl) {
  const $form = $('.schedule-report form');
  $form.on('submit', evt => {
    const values = {};
    evt.preventDefault();

    $form.find(':input').each(function() {
      const $el = $(this);
      values[$el.attr('id')] = $el.val();
    });

    generateTemplate(scheduleUrl, {
      report_template_report: { input_values: values },
    });
  });

  let currentValue;
  const handleChange = () => {
    const previousValue = currentValue;
    currentValue = store.getState().templates;

    if (previousValue !== currentValue) {
      $form.toggle(!currentValue.polling);
    }
  };
  const unsubscribe = store.subscribe(handleChange);

  $(document).on('page:before-unload', () => {
    unsubscribe();
  });
}

function updateVisibilityAfterInputTypeChange(select) {
  const fieldset = select.closest('fieldset');
  fieldset.find('div.custom_input_type_fields').hide();
  fieldset.find(`div.${select.val()}_input_type`).show();
}

export const generateTemplate = (url, templateInputData) =>
  store.dispatch(TemplateActions.generateTemplate(url, templateInputData));
