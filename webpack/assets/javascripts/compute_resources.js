import $ from 'jquery';

export function vsphereClusterChanged(item) {
  let handleRequest = (request, items) => {
      for (let i = 0; i < request.length; i++) {
        let option = request[i].name;

        $('<option>').text(option).val(option).appendTo(items);
      }
  };

  let handleDatastoreRequest = (request, items) => {
    let data = request.datastores;

    for (let i = 0; i < data.length; i++) {
      let id = data[i].datastore.name;
      let text = datastoreStats(data[i].datastore);

      $('<option>').text(text).val(id).appendTo(items);
    }
  };

  vsphereGetClusterItems(item,
      {
        selector: 'select[id*=resource_pool]',
        dataField: 'poolurl',
        errorMsg: window.__('Error loading resource pools: %s'),
        requestHandler: handleRequest
      }
      );
  vsphereGetClusterItems(item,
      {
        selector: 'select[id*=datastore]',
        dataField: 'datastoreurl',
        errorMsg: window.__('Error loading datastores: %s'),
        requestHandler: handleDatastoreRequest
      }
      );
  vsphereGetClusterItems(item,
      {
        selector: 'select.vmware_network',
        dataField: 'networkurl',
        errorMsg: window.__('Error loading networks: %s'),
        requestHandler: handleRequest
      }
      );
}

function vsphereGetClusterItems(item, options) {
  let data = {'cluster_id': $(item).val()};
  let url = $(item).data(options.dataField);
  let selectboxes = $(options.selector);

  selectboxes.indicator_show();
  window.tfm.tools.showSpinner();
  selectboxes.select2('destroy').empty();
  clearFieldError($(item));
  $.ajax({
    type: 'get',
    url: url,
    data: data,
    complete: function () {
      selectboxes.indicator_hide();
      window.tfm.tools.hideSpinner();
    },
    error: (jqXHR, status, error) => {
      setFieldError($(item), window.Jed.sprintf(options.errorMsg, error));
    },
    success: (request) => {
      options.requestHandler(request, selectboxes);
      vsphereStoragePodLoad();
      window.activate_select2($(item).closest('form'));
    }
  });
}

export function datastoreStats(datastore) {
  if (!(datastore.free && datastore.prov && datastore.total)) {
    return datastore.name;
  }

  let opts = {
    name: datastore.name,
    free: datastore.free,
    prov: datastore.prov,
    total: datastore.total
  };

  return window.Jed.sprintf(
      window.__('%(name)s (free: %(free)s prov: %(prov)s total: %(total)s)'),
      opts);
}

export function setFieldError(field, text) {
  let formGroup = field.parents('.form-group').first();
  let helpBlock = formGroup.children('.help-block').first();
  let span = $(document.createElement('span'));

  formGroup.addClass('has-error');
  span.addClass('error-message').html(text);
  helpBlock.prepend(span);
}

export function clearFieldError(field) {
  let formGroup = field.parents('.form-group').first();
  let errorBlock = formGroup.children('.help-block').children('.error-message');

  formGroup.removeClass('has-error');
  errorBlock.remove();
}

export function vsphereStoragePodSelected(item) {
  let selected = $(item).val();
  let datastore = $('select[id*=datastore]');

  if (!selected || selected.length === 0) {
    enableVsphereDropdown(datastore);
  } else {
    disableVsphereDropdown(datastore);
  }
  return false;
}

export function vsphereStoragePodLoad() {
  let items = $('select[id*=storage_pod]');

  if (items.length < 1) {
    return false;
  }
  items.each(function () {
    let selected = $(this).val();

    if (selected || !(selected.length === 0)) {
      let datastore = $('select[id*=datastore]');

      disableVsphereDropdown(datastore);
    }
  });
  return false;
}

function disableVsphereDropdown(item) {
  item.attr('disabled', true);
}

function enableVsphereDropdown(item) {
  item.attr('disabled', false);
}
