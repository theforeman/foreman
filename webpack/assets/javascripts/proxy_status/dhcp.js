const tools = require('../foreman_tools');

// replace with module imports once proxy_status.js, application.js and i18.js move to modules
const __ = window.__;
// const showProxies = window.showProxies;
// const setTab = window.setTab;

// fetch leases and reservations when there is an anchor to a subnet details on page load
function loadSubnetOnContentLoad() {
  let anchor = document.location.hash;

  anchor = anchor.slice(1, anchor.length);

  if (/^(\d{1,3}-){3}\d{1,3}$/.test(anchor)) {
    let element = $('#proxy-dhcp-tab').find('[data-placeholder=' + anchor + ']').first();

    loadSubnet(element);
  }
}

function currentSubnet() {
  return $('#proxy-dhcp-tab li.active a').first().data('dhcp-subnet');
}

function parameterizeSubnet(address) {
  return address.split('.').join('-');
}

function loadSubnet(element) {
  let url = $(element).data('url'),
      network = $(element).data('placeholder'),
      dhcpSubnet = $(element).data('dhcp-subnet'),
      placeholder = $('#subnet-placeholder' + network).first();

  hideHosts(placeholder);
  tools.showSpinner();
  $.ajax({
    type: 'get',
    url: url,
    data: { 'dhcp_subnet': dhcpSubnet },
    success: (response) => {
      $(response).insertAfter(placeholder);
      tfm.tools.activateDatatables();
      tfm.tools.hideSpinner();
    },
    error: (response) => {
      let div = $("<div class='top-margin'></div>");

      div.append($(response.responseText));
      div.insertAfter(placeholder);
      tfm.tools.hideSpinner();
    }
  });
}

function loadSubnetOnClick() {
  $('.subnet-menu').each((index, item) => {
    // when using arrow function, 'this' is undefined instead of clicked link
    $(item).click(function () {
      loadSubnet(this);
    });
  });
}

function hideHosts(placeholder) {
  placeholder.next().remove();
}

export function createModal(record) {
  let item = '';

  for (let key in record) {
    if (record.hasOwnProperty(key)) {
      item = item + record[key] + ', ';
    }
  }
  $('#dhcp-modal-placeholder').empty().append('<span>' + item.slice(0, -2) + '</span>');
  $('#dhcp-modal-placeholder span').data('record', record);
  $('#dhcp-modal').modal();
}

export function activateDhcpTables() {
  tfm.proxyStatus.common.showProxies();
  tfm.proxyStatus.common.setTab();
  loadSubnetOnContentLoad();
  loadSubnetOnClick();
}

export function deleteRecord(element, url) {
  let record = $('#dhcp-modal-placeholder span').data('record'),
      subnet = currentSubnet();

  let placeholder = $('#subnet-placeholder' + parameterizeSubnet(subnet.network)).first();

  tools.showSpinner();
  $.ajax({
    method: 'delete',
    url: url,
    data: { 'record': record, 'dhcp_subnet': subnet },
    success: (response) => {
      hideHosts(placeholder);
      $(response).insertAfter(placeholder);
      tfm.tools.activateDatatables();
      tfm.tools.hideSpinner();
      $('#dhcp-modal').modal('hide');
      $.jnotify(__('Record successfully deleted'), 'success', false);
    },
    error: (response) => {
      tfm.tools.hideSpinner();
      $('#dhcp-modal').modal('hide');
      $.jnotify(response.responseJSON.message, 'error', true);
    }
  });
}
