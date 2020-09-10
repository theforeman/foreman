/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-attr */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-html */
/* eslint-disable jquery/no-class */

import $ from 'jquery';
import { showSpinner, hideSpinner } from '../foreman_tools';
import { sprintf, translate as __ } from '../react_app/common/I18n';

export function schedulerHintFilterSelected(item) {
  const filter = $(item).val();

  if (filter === '') {
    $('#scheduler_hint_wrapper').empty();
  } else {
    const url = $(item).attr('data-url');
    // eslint-disable-next-line no-undef
    const data = serializeForm().replace('method=patch', 'method=post');

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
          sprintf(
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
