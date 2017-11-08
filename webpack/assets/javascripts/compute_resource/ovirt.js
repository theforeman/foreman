import $ from 'jquery';
import { showSpinner } from '../foreman_tools';
import { testConnection } from '../foreman_compute_resource';

export function templateSelected(item) {
  const template = $(item).val();

  if (!item.disabled) {
    const url = $(item).attr('data-url');

    showSpinner();
    $.ajax({
      type: 'post',
      url,
      data: `template_id=${template}`,
      success(result) {
        $('[id$=_memory]').val(result.memory);
        $('[id$=_cores]').val(result.cores);
        $('#network_interfaces')
          .children('.fields')
          .remove();
        $.each(result.interfaces, function() {
          addNetworkInterface(this);
        });
        $('#storage_volumes .children_fields >.fields').remove();
        $.each(result.volumes, function() {
          addVolume(this);
        });
        const templateSelector = $('#host_compute_attributes_template');

        if (templateSelector.is(':disabled')) {
          templateSelector.val(result.id).trigger('change');
        }
      },
      complete() {
        // eslint-disable-next-line no-undef
        reloadOnAjaxComplete(item);
      },
    });
  }
}

// fill in the template interfaces.
function addNetworkInterface({ name, network }) {
  const nestedFields = $('#network_interfaces .add_nested_fields');
  // no network interfaces update when the network editing is not allowed by the compute resource

  if (nestedFields.length > 0) {
    // eslint-disable-next-line no-undef
    const newId = add_child_node(nestedFields);

    $(`[id$=${newId}_name]`).val(name);
    $(`[id$=${newId}_network]`).val(network);
  }
}

// fill in the template volumes.
// eslint-disable-next-line camelcase
function addVolume({ size_gb, storage_domain, bootable, id }) {
  // eslint-disable-next-line no-undef
  const newId = add_child_node($('#storage_volumes .add_nested_fields'));

  disableElement($(`[id$=${newId}_size_gb]`).val(size_gb));
  disableElement($(`[id$=${newId}_storage_domain]`).val(storage_domain));
  disableElement($(`[id$=${newId}_bootable_true]`).attr('checked', bootable));
  if (id) {
    $(`[id$=${newId}_id]`).val(id);
  }
  $(`[id$=${newId}_storage_domain]`)
    .next()
    .hide();
}

function disableElement(element) {
  element
    .clone()
    .attr('type', 'hidden')
    .appendTo(element);
  element.attr('disabled', 'disabled');
}

export function bootableRadio(item) {
  let disabled = $('[id$=_bootable_true]:disabled:checked:visible');

  $('[id$=_bootable_true]').prop('checked', false);
  if (disabled.length > 0) {
    disabled.prop('checked', true);
  } else {
    $(item).prop('checked', true);
  }
}
export function clusterSelected(item) {
  const cluster = $(item).val();
  const url = $(item).attr('data-url');

  showSpinner();
  $.ajax({
    type: 'post',
    url,
    data: `cluster_id=${cluster}`,
    success(result) {
      let networkOptions = $('select[id$=_network]').empty();

      $.each(result, function() {
        networkOptions.append(
          $('<option />')
            .val(this.id)
            .text(this.name)
        );
      });
    },
    complete() {
      // eslint-disable-next-line no-undef
      reloadOnAjaxComplete(item);
    },
  });
}

// used by test connection
export function datacenterSelected(item) {
  // eslint-disable-next-line no-undef
  testConnection($('#test_connection_button'));
}
