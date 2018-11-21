import Jed from 'jed';
import { deprecateObjectProperty } from '../../foreman_tools';

const cheveronPrefix = () => (window.I18N_MARK ? '\u00BB' : '');
const cheveronSuffix = () => (window.I18N_MARK ? '\u00AB' : '');

const documentLocale = () =>
  document.getElementsByTagName('html')[0].lang.replace(/-/g, '_');

const getLocaleData = () => {
  const locales = window.locales || {};
  const locale = documentLocale();

  if (locales[locale] === undefined) {
    // eslint-disable-next-line no-console
    console.log(`could not load translations for ${locale} locale, falling back to default locale.`);
    return { domain: 'app', locale_data: { app: { '': {} } } };
  }

  return locales[locale];
};

export const jed = new Jed(getLocaleData());

export const translate = (...args) => `${cheveronPrefix()}${jed.gettext(...args)}${cheveronSuffix()}`;
export const ngettext = (...args) => `${cheveronPrefix()}${jed.ngettext(...args)}${cheveronSuffix()}`;

export const { sprintf } = jed;

const i18n = {
  translate, ngettext, jed, sprintf,
};
export default i18n;
window.__ = translate;
window.n__ = ngettext;
window.Jed = jed;
window.i18n = jed;

deprecateObjectProperty(window, 'i18n', 'tfm.i18n');
deprecateObjectProperty(window, 'Jed', 'tfm.i18n.jed');
