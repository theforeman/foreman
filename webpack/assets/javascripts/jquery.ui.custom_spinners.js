/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-ready */
/* eslint-disable no-param-reassign */
/* eslint-disable func-names */

import $ from 'jquery';

const megabyte = 1024 * 1024;
const gigabyte = 1024 * megabyte;

$(() => {
  $.widget('ui.limitedSpinner', $.ui.spinner, {
    options: {
      softMaximum: 0,
      min: 1,
      errorTarget: null,
    },
    validate() {
      return this._validate();
    },
    _validate() {
      if (this.options.softMaximum !== 0) {
        this.options.errorTarget.toggle(
          this.value() > this.options.softMaximum
        );
      }
    },
    _spin(step, event) {
      const result = this._super(step, event);

      this._validate();
      return result;
    },
  });

  $.widget('ui.byteSpinner', $.ui.limitedSpinner, {
    options: {
      step: 1,
      min: 1,
      incremental: false,
      valueTarget: null,
    },
    updateValueTarget() {
      this.options.valueTarget.val(this.value());
    },
    _gigabyteSpin(step) {
      if (step > 0) {
        if (step % gigabyte === 0) {
          step = gigabyte;
        } else {
          step = gigabyte - (this.value() % gigabyte);
        }
      } else if (step < 0) {
        if (this.value() % gigabyte === 0) {
          step = -1 * gigabyte;
        } else {
          step = -1 * (this.value() % gigabyte);
        }
      }
      return step;
    },
    _megabyteSpin(step) {
      const megabyteStep = step * 256 * megabyte;

      if (this.value() + megabyteStep > gigabyte) {
        step = gigabyte - this.value();
      } else if (this.value() + megabyteStep < megabyte) {
        step *= this.value() - megabyte;
      } else if (this.value() === megabyte && step > 0) {
        step = 255 * megabyte;
      } else {
        step = megabyteStep;
      }
      return step;
    },
    _spin(step, event) {
      let result = null;

      if (
        (this.value() > gigabyte && step < 0) ||
        (this.value() >= gigabyte && step > 0)
      ) {
        step = this._gigabyteSpin(step);
      } else {
        step = this._megabyteSpin(step);
      }

      result = this._super(step, event);
      this.updateValueTarget();

      return result;
    },
    _parse(value) {
      if (typeof value === 'string') {
        if (value.match(/gb$/i)) {
          return parseFloat(value) * gigabyte;
        } else if (value.match(/mb$/i) || parseInt(value, 10) < megabyte) {
          return parseInt(value, 10) * megabyte;
        }
      }
      return value;
    },
    // prints value with unit, if it's multiple of gigabytes use GB, otherwise format in MB
    _format: value =>
      value % gigabyte === 0
        ? `${value / gigabyte} GB`
        : `${value / megabyte} MB`,
  });
});

export function initAll(selection = null) {
  // might be called with Event-argument, if used as EventHandler
  if (
    selection !== null &&
    typeof selection === 'object' &&
    (selection.hasOwnProperty('originalEvent') ||
      selection.constructor === $.Event)
  ) {
    selection = null;
  }
  initByte(selection);
  initCounter(selection);
}

export function initCounter(selection = null) {
  // Do not initialize form_templates
  $('input.counter_spinner', selection)
    .not('.form_template input.counter_spinner')
    .each(function() {
      const field = $(this);
      const errorMessage = field.closest('.form-group').find('.maximum-limit');
      let min = field.data('min');
      min = typeof min === 'number' ? min : 1;

      field.limitedSpinner({
        softMaximum: field.data('softMax'),
        errorTarget: errorMessage,
        min,
      });

      field.change(() => {
        field.limitedSpinner('validate');
      });

      field
        .parents('div.form-group')
        .find('label a')
        .popover();
    });
}

export function initByte(selection = null) {
  // Do not initialize form_templates
  $('input.byte_spinner', selection)
    .not('.form_template input.byte_spinner')
    .each(function() {
      const field = $(this);
      const errorMessage = field.closest('.form-group').find('.maximum-limit');
      const valueTarget = field
        .closest('.form-group')
        .find('.real-hidden-value');

      field.byteSpinner({
        valueTarget,
        softMaximum: field.data('softMax'),
        errorTarget: errorMessage,
      });

      field.change(() => {
        field.byteSpinner('updateValueTarget');
        field.byteSpinner('validate');
      });

      field
        .parents('div.form-group')
        .find('label a')
        .popover();
    });
}
