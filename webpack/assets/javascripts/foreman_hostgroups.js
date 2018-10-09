import $ from 'jquery';
import { translate as __ } from './react_app/common/I18n';

export function checkForUnavailablePuppetclasses() {
  const unavailableClasses = $(
    '#puppet_klasses #selected_classes .unavailable'
  );
  const puppetKlassesTab = $('#puppet_klasses');
  const tab = puppetKlassesTab
    .closest('form')
    .find('.nav-tabs a[href="#puppet_klasses"]');
  const warningMessage = __(
    'Some Puppet Classes are unavailable in the selected environment'
  );
  const warning = `<div class="alert alert-warning" id="puppetclasses_unavailable_warning">
      <span class="pficon pficon-warning-triangle-o"></span>
      ${warningMessage}
    </span>`;

  if (unavailableClasses.size() > 0) {
    tab.prepend('<span class="pficon pficon-warning-triangle-o"></span> ');
    puppetKlassesTab.prepend(warning);
  } else {
    puppetKlassesTab.find('#puppetclasses_unavailable_warning').remove();
    tab.find('.pficon-warning-triangle-o').remove();
  }
}
