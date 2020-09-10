/* eslint-disable jquery/no-prop */
/* eslint-disable jquery/no-data */
/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-text */

import $ from 'jquery';
import store from '../react_app/redux';
import { translate as __ } from '../react_app/common/I18n';
import { showSpinner, hideSpinner } from '../foreman_tools';
import { changeCluster } from '../react_app/redux/actions/hosts/storage/vmware';

export function onClusterChange(item) {
  const clusterId = $(item).val();
  const resPoolsUrl = $(item).data('poolsurl');
  const networksUrl = $(item).data('networksurl');

  store.dispatch(changeCluster(clusterId));

  fetchResourcePools(resPoolsUrl, clusterId);
  fetchNetworks(networksUrl, clusterId);
}

function fetchResourcePools(url, clusterId) {
  // eslint-disable-next-line camelcase
  const data = { cluster_id: clusterId };
  const $selectbox = $('select[id$="resource_pool"]');

  if (!clusterId) {
    $selectbox.select2('destroy').empty();
    $('<option>')
      .text(__('Please select a cluster'))
      .val('')
      .appendTo($selectbox);
    $selectbox.prop('disabled', true).select2();
    return;
  }

  showSpinner();
  $.ajax({
    type: 'get',
    url,
    data,
    complete() {
      hideSpinner();
    },
    success(request) {
      $selectbox
        .select2('destroy')
        .empty()
        .prop('disabled', false);
      request.forEach(({ name }) => {
        $('<option>')
          .text(name)
          .val(name)
          .appendTo($selectbox);
      });
      $selectbox.select2();
    },
  });
}

function fetchNetworks(url, clusterId) {
  const $networkOptions = $('select[id$=_network]');

  showSpinner();
  $.ajax({
    type: 'get',
    url,
    data: { cluster_id: clusterId },
    success(response) {
      $networkOptions.empty();

      $.each(response.results, (idx, value) => {
        $networkOptions.append(new Option(value.name, value.id, false, false));
      });

      window.update_interface_table();
    },
    complete() {
      hideSpinner();
    },
  });
}
