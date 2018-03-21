import Jed from 'jed';
import { deprecateObjectProperty } from '../../foreman_tools';

const cheveronPrefix = () => (window.I18N_MARK ? '\u00BB' : '');
const cheveronSuffix = () => (window.I18N_MARK ? '\u00AB' : '');

const emptyLocales = {
  en: { domain: 'app', locale_data: { app: { '': {} } } },
};

const locales = window.locales || emptyLocales;
let locale = document.getElementsByTagName('html')[0].lang;

locale = locale.length === 0 ? 'en' : locale.replace(/-/g, '_');
export const jed = new Jed(locales[locale]);

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
