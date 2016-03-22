//= require gettext/all

$(function() {
  // Add normal gettext aliases with gettext_i18n_rails_js to enable extraction
  // when SETTINGS[:mark_translated] is enabled, wrap all strings
  if (typeof(I18N_MARK) != 'undefined' && I18N_MARK) {
    window.__ = function() { return '\u00BB' + i18n.gettext.apply(i18n, arguments) + '\u00AB' };
    window.n__ = function() { return '\u00BB' + i18n.ngettext.apply(i18n, arguments) + '\u00AB' };
  }
});
