import $ from 'jquery';

const megabyte = 1024 * 1024;
const gigabyte = 1024 * megabyte;

$(function() {
  $.widget('ui.limitedSpinner', $.ui.spinner, {
    options: {
      softMaximum: 0,
      errorTarget: null,
    },
    validate: function() {
      return this._validate();
    },
    _validate: function() {
      if (this.options.softMaximum !== 0) {
        this.options.errorTarget.toggle(
          this.value() > this.options.softMaximum
        );
      }
    },
    _spin: function(step, event) {
      let result = this._super(step, event);

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
    updateValueTarget: function() {
      this.options.valueTarget.val(this.value());
    },
    _gigabyteSpin: function(step) {
      if (step > 0) {
        if (step % gigabyte === 0) {
          step = gigabyte;
        } else {
          step = gigabyte - this.value() % gigabyte;
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
    _megabyteSpin: function(step) {
      const megabyteStep = step * 256 * megabyte;

      if (this.value() + megabyteStep > gigabyte) {
        step = gigabyte - this.value();
      } else if (this.value() + megabyteStep < megabyte) {
        step = step * (this.value() - megabyte);
      } else if (this.value() === megabyte && step > 0) {
        step = 255 * megabyte;
      } else {
        step = megabyteStep;
      }
      return step;
    },
    _spin: function(step, event) {
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
    _parse: function(value) {
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
        ? value / gigabyte + ' GB'
        : value / megabyte + ' MB',
  });
});

export function initAll() {
  initByte();
  initCounter();
}

export function initCounter() {
  $('input.counter_spinner').each(function() {
    let field = $(this);
    let errorMessage = field.closest('.form-group').find('.maximum-limit');

    field.limitedSpinner({
      softMaximum: field.data('softMax'),
      errorTarget: errorMessage,
      min: 1,
    });

    field.change(function() {
      field.limitedSpinner('validate');
    });

    field
      .parents('div.form-group')
      .find('label a')
      .popover();
  });
}

export function initByte() {
  $('input.byte_spinner').each(function() {
    let field = $(this);
    let errorMessage = field.closest('.form-group').find('.maximum-limit');
    let valueTarget = field.closest('.form-group').find('.real-hidden-value');

    field.byteSpinner({
      valueTarget: valueTarget,
      softMaximum: field.data('softMax'),
      errorTarget: errorMessage,
    });

    field.change(function() {
      field.byteSpinner('updateValueTarget');
      field.byteSpinner('validate');
    });

    field
      .parents('div.form-group')
      .find('label a')
      .popover();
  });
}
