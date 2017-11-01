import $ from 'jquery';
import { showSpinner, hideSpinner } from '../foreman_tools';

export function schedulerHintFilterSelected(item) {
  let filter = $(item).val();

  if (filter === '') {
    $('#scheduler_hint_wrapper').empty();
  } else {
    let url = $(item).attr('data-url');
    // eslint-disable-next-line no-undef
    let data = serializeForm().replace('method=patch', 'method=post');

    showSpinner();
    $.ajax({
      type: 'post',
      url,
      data,
      complete() {
        hideSpinner();
      },
      error(jqXHR, status, error) {
        $('#scheduler_hint_wrapper').html(
          // eslint-disable-next-line no-undef
          Jed.sprintf(
            __('Error loading scheduler hint filters information: %s'),
            error
          )
        );
        $('#compute_resource_tab a').addClass('tab-error');
      },
      success(result) {
        $('#scheduler_hint_wrapper').html(result);
      },
    });
  }
}
