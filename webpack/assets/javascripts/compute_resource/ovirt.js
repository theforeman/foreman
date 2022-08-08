/* eslint-disable jquery/no-each */
/* eslint-disable jquery/no-text */
/* eslint-disable jquery/no-data */
/* eslint-disable jquery/no-sizzle */
/* eslint-disable jquery/no-hide */
/* eslint-disable jquery/no-attr */
/* eslint-disable jquery/no-ajax */
/* eslint-disable jquery/no-trigger */
/* eslint-disable jquery/no-val */
/* eslint-disable jquery/no-prop */
/* eslint-disable func-names */

import $ from 'jquery';
import { showSpinner } from '../foreman_tools';
import { testConnection } from '../foreman_compute_resource';

export function templateSelected(item) {
  const template = $(item).val();

  if (template === null) {
    return;
  }

  const url = $(item).attr('data-url');

  showSpinner();
  $.ajax({
    type: 'post',
    url,
    data: `template_id=${template}`,
    success(result) {
      // As Instance Type values will take precence over templates values,
      // we don't update memory/cores values if  instance type is already selected
      if (!$('#host_compute_attributes_instance_type').val()) {
        updateCoresAndSockets(result);
        setMemoryInputProps({ value: result.memory });
        $('[id$=_ha]').prop('checked', result.ha);
      }
      $('#network_interfaces')
        .children('.fields')
        .remove();
      $.each(result.interfaces, function() {
        addNetworkInterface(this);
      });
      $('#storage_volumes .children_fields >.fields').remove();
      $.each(result.volumes, function() {
        // Change variable name because 'interface' is a reserved keyword.
        // eslint-disable-next-line dot-notation
        this.disk_interface = this['interface'];
        addVolume(this);
      });
      const templateSelector = $('#host_compute_attributes_template');

      if (templateSelector.siblings('.select2-container-disabled').length > 0) {
        templateSelector.val(result.id);
      }
    },
    complete() {
      // eslint-disable-next-line no-undef
      reloadOnAjaxComplete(item);
    },
  });
}

export function instanceTypeSelected(item) {
  const instanceType = $(item).val();

  if (!item.disabled) {
    const url = $(item).attr('data-url');

    showSpinner();
    $.ajax({
      type: 'post',
      url,
      data: `instance_type_id=${instanceType}`,
      success(result) {
        if (result.name != null) {
          setMemoryInputProps({ value: result.memory });
          updateCoresAndSockets(result);
          $('[id$=_ha]').prop('checked', result.ha);
        }
        setMemoryInputProps({ disabled: result.name != null });
        disableCoresAndSockets(result);
        ['_ha'].forEach(name =>
          $(`[id$=${name}]`).prop('readOnly', result.name != null)
        );
        const instanceTypeSelector = $(
          '#host_compute_attributes_instance_type'
        );

        if (instanceTypeSelector.is(':disabled')) {
          instanceTypeSelector.val(result.id).trigger('change');
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
function addVolume({
  size_gb: sizeGb,
  storage_domain: storageDomain,
  sparse,
  bootable,
  id,
  disk_interface: diskInterface,
  wipe_after_delete: wipeAfterDelete,
}) {
  // eslint-disable-next-line no-undef
  const newId = add_child_node($('#storage_volumes .add_nested_fields'));

  disableElement($(`[id$=${newId}_size_gb]`).val(sizeGb));
  $(`[id$=${newId}_storage_domain]`).val(storageDomain);
  disableElement($(`[id$=${newId}_interface]`).val(diskInterface));
  disableElement($(`[id$=${newId}_bootable_true]`).attr('checked', bootable));
  disableElement(
    $(`[id$=${newId}_wipe_after_delete]`).prop('checked', wipeAfterDelete)
  );
  if (id) {
    $(`[id$=${newId}_id]`).val(id);
  }
  $(`[id$=${newId}_storage_domain]`)
    .next()
    .hide();
}

function setMemoryInputProps(props) {
  const memoryInputElement = getComponentByWrapperId('memory-input');
  memoryInputElement.reactProps = {
    ...memoryInputElement.reactProps,
    ...props,
  };
}

function updateCoresAndSockets(result) {
  const coresInputElement = getComponentByWrapperId('cores-input');
  coresInputElement.reactProps = {
    ...coresInputElement.reactProps,
    value: result.cores,
  };
  const socketInputElement = getComponentByWrapperId('sockets-input');
  socketInputElement.reactProps = {
    ...socketInputElement.reactProps,
    value: result.sockets,
  };
}

function disableCoresAndSockets(result) {
  const coresInputElement = getComponentByWrapperId('cores-input');
  coresInputElement.reactProps = {
    ...coresInputElement.reactProps,
    disabled: result.name != null,
  };
  const socketInputElement = getComponentByWrapperId('sockets-input');
  socketInputElement.reactProps = {
    ...socketInputElement.reactProps,
    disabled: result.name != null,
  };
}

function getComponentByWrapperId(wrapperId) {
  return document
    .getElementById(wrapperId)
    .getElementsByTagName('foreman-react-component')[0];
}

function disableElement(element) {
  element
    .clone()
    .attr('type', 'hidden')
    .appendTo(element);
  element.attr('disabled', 'disabled');
}

export function bootableRadio(item) {
  const disabled = $('[id$=_bootable_true]:disabled:checked:visible');

  $('[id$=_bootable_true]').prop('checked', false);
  if (disabled.length > 0) {
    disabled.prop('checked', true);
  } else {
    $(item).prop('checked', true);
  }
}
export function clusterSelected(item) {
  const cluster = $(item).val();
  const url = $(item).data('url');

  showSpinner();
  $.ajax({
    type: 'post',
    url,
    data: `cluster_id=${cluster}`,
    success(result) {
      const networkOptions = $('select[id$=_network]').empty();

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

export function vnicSelected(item) {
  const selectedVnicProfile = $(item).val();
  if (selectedVnicProfile) {
    const itemId = $(item).attr('id');
    const nicId = itemId.match(/_([0-9]*)_vnic_profile/)[1];
    const idNetwork = `id$=_${nicId}_network`;

    const vnicOptions = JSON.parse(
      $('select[id$=_vnic_profile]')[1].getAttribute('data-profiles')
    );
    const networkOptions = JSON.parse(
      $('select[id$=_vnic_profile]')[1].getAttribute('data-networks')
    );

    const vnicNetwork = vnicOptions.filter(
      vnicOption => vnicOption.id === selectedVnicProfile
    )[0].network;
    const networkObj = networkOptions.filter(
      network => network.id === vnicNetwork.id
    )[0];
    const networkSelect = $(`select[${idNetwork}]`);
    networkSelect.empty();
    networkSelect.append(
      $('<option />')
        .val(networkObj.id)
        .text(networkObj.name)
    );
    networkSelect.val(networkObj.id).trigger('change');
  }
}
