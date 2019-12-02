/* eslint-disable jquery/no-closest */
/* eslint-disable jquery/no-attr */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-find */
/* eslint-disable jquery/no-parent */

import $ from 'jquery';
import { showSpinner } from '../foreman_tools';

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

    showSpinner();
    $.ajax({
      type: 'post',
      url,
      data: `template_id=${template}`,
      success(result) {
        const capacity = $('#storage_volumes')
          .children('.fields')
          .find('[id$=capacity]')[0];

        if (
          parseInt(capacity.value.slice(0, -1), 10) <
          parseInt(result.capacity, 10)
        ) {
          capacity.value = `${result.capacity}G`;
        }
        $('#storage_volumes')
          .children('.fields')
          .find('[id$=format_type]')[0].value = 'qcow2';
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
