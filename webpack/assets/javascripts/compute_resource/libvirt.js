/* eslint-disable jquery/no-closest */
/* eslint-disable jquery/no-attr */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-parent */
/* eslint-disable jquery/no-text */
/* eslint-disable jquery/no-class */

import $ from 'jquery';
import { showSpinner } from '../foreman_tools';
import { translate as __ } from '../react_app/common/I18n';

export function networkSelected(item) {
  const selected = $(item).val();
  const bridge = $(item)
    .parentsUntil('.fields')
    .parent()
    .find('#bridge');
  const nat = $(item)
    .parentsUntil('.fields')
    .parent()
    .find('#nat');

  switch (selected) {
    case '':
      disableDropdown(bridge);
      disableDropdown(nat);
      break;
    case 'network':
      disableDropdown(bridge);
      enableDropdown(nat);
      break;
    case 'bridge':
      disableDropdown(nat);
      enableDropdown(bridge);
      break;
    default:
      break;
  }
  return false;
}

function disableDropdown(item) {
  item.hide();
  item.attr('disabled', true);
}

function enableDropdown(item) {
  item.attr('disabled', false);
  item.find(':input').attr('disabled', false);
  item.show();
}

export function imageSelected(item) {
  const template = $(item).val();

  if (template) {
    const url = $(item).attr('data-url');
    // For some reason there are two help blocks
    // so we need to select the correct one
    const help = $('#image_selection .form-group > div > .help-block');

    showSpinner();

    $.ajax({
      type: 'post',
      url,
      data: `template_id=${template}`,
      success(result) {
        help.empty();

        const capacity = $(
          '#host_compute_attributes_volumes_attributes_0_capacity'
        );

        const capacityInForm = parseInt(
          capacity.attr('value').slice(0, -1),
          10
        );
        const capacityFromImage = parseInt(result.capacity, capacityInForm);

        if (capacityInForm < capacityFromImage) {
          capacity.attr('value', `${capacityFromImage}G`);
        }

        $('#storage_volumes .fields')
          .find('#host_compute_attributes_volumes_attributes_0_format_type')
          .select2('val', 'qcow2');
      },
      error() {
        help.html(
          $('<span />')
            .addClass('text-danger')
            .text(__('Image not found'))
        );
      },
      complete() {
        // eslint-disable-next-line no-undef
        reloadOnAjaxComplete(item);
      },
    });
  }
}

export function allocationSwitcher(element, action) {
  const previous = $(element)
    .parent()
    .find('.active');

  previous.removeClass('active');

  const capacity = $(element)
    .closest('.fields')
    .find('[id$=capacity]')[0];
  const allocation = $(element)
    .closest('.fields')
    .find('[id$=allocation]')[0];

  switch (action) {
    case 'None':
      $(allocation).attr('readonly', 'readonly');
      allocation.value = '0G';
      break;
    case 'Size':
      $(allocation).removeAttr('readonly');
      allocation.value = '0G';
      $(allocation).focus();
      break;
    case 'Full':
      $(allocation).attr('readonly', 'readonly');
      allocation.value = capacity.value;
      break;
    default:
      break;
  }

  $(element).button('toggle');
  return false;
}
