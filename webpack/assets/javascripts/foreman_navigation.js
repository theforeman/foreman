import $ from 'jquery';

function markActiveMenu() {
  const link = `[href='${window.location.pathname}']`;
  const currentLoc = $('#location-dropdown .nav-item-iconic').text();
  const currentOrg = $('#organization-dropdown .nav-item-iconic').text();

  $('.list-group-item.secondary-nav-item-pf')
    .has(link)
    .addClass('active');
  if (currentLoc) {
    $(
      `.nav-pf-secondary-nav .list-group-item:contains("${currentLoc.trim()}")`
    ).addClass('active');
  }
  if (currentOrg) {
    $(
      `.nav-pf-secondary-nav .list-group-item:contains("${currentOrg.trim()}")`
    ).addClass('active');
  }
}

export function init() {
  $().setupVerticalNavigation(false);
  $(document).on('mouseover', '#vertical-nav', () => {
    $('.org-switcher').removeClass('open');
  });
  $(document).on('click', '.nav-pf-secondary-nav', () => {
    $('#vertical-nav').removeClass('hover-secondary-nav-pf');
    $('#vertical-nav').removeClass('secondary-visible-pf');
    $('.container-pf-nav-pf-vertical').removeClass('secondary-visible-pf');
  });
  markActiveMenu();
}

export function activate() {
  // a workaround to enable turbolinks works with pf vertical navigation
  $.fn.setupVerticalNavigation.self = undefined;
  $(document).off(
    'mouseenter.pf.tertiarynav.data-api',
    '.secondary-nav-item-pf'
  );
  $(document).off(
    'mouseleave.pf.tertiarynav.data-api',
    '.secondary-nav-item-pf'
  );
}
