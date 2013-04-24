//= require_tree ./locale
//= require gettext/all

$(function() {
  // Add normal gettext aliases with gettext_i18n_rails_js to enable extraction
  // when SETTINGS[:mark_translated] is enabled, wrap all strings
  if (typeof(I18N_MARK) != 'undefined' && I18N_MARK) {
    window._ = function() { return 'X' + i18n.gettext.apply(i18n, arguments) + 'X' };
    window.n_ = function() { return 'X' + i18n.ngettext.apply(i18n, arguments) + 'X' };
  } else {
    window._ = window.__;
    window.n_ = window.n__;
  }
});
