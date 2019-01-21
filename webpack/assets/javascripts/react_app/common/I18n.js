import Jed from 'jed';
import { addLocaleData } from 'react-intl';
import { deprecateObjectProperty } from '../../foreman_tools';
import { runningInPhantomJS } from './helpers';

class IntlLoader {
  constructor(locale, timezone) {
    this.fallbackIntl = !global.Intl || runningInPhantomJS();

    [this.locale] = locale.split('-');
    this.timezone = this.fallbackIntl ? 'UTC' : timezone;
    this.ready = this.init();
  }

  async init() {
    await this.fetchIntl();
    addLocaleData(
      await import(/* webpackChunkName: 'react-intl/locale/[request]' */ `react-intl/locale-data/${
        this.locale
      }`)
    );
    return true;
  }

  async fetchIntl() {
    if (this.fallbackIntl) {
      global.Intl = await import(/* webpackChunkName: "intl" */ 'intl');
      await import(/* webpackChunkName: 'intl/locale/[request]' */ `intl/locale-data/jsonp/${
        this.locale
      }`);
    }
  }
}

const [htmlElemnt] = document.getElementsByTagName('html');
const langAttr = htmlElemnt.getAttribute('lang') || 'en';
const timezoneAttr = htmlElemnt.getAttribute('data-timezone') || 'UTC';

export const intl = new IntlLoader(langAttr, timezoneAttr);

const cheveronPrefix = () => (window.I18N_MARK ? '\u00BB' : '');
const cheveronSuffix = () => (window.I18N_MARK ? '\u00AB' : '');

const documentLocale = () =>
  document.getElementsByTagName('html')[0].lang.replace(/-/g, '_');

const getLocaleData = () => {
  const locales = window.locales || {};
  const locale = documentLocale();

  if (locales[locale] === undefined) {
    // eslint-disable-next-line no-console
    console.log(
      `could not load translations for ${locale} locale, falling back to default locale.`
    );
    return { domain: 'app', locale_data: { app: { '': {} } } };
  }

  return locales[locale];
};

export const jed = new Jed(getLocaleData());

export const translate = (...args) =>
  `${cheveronPrefix()}${jed.gettext(...args)}${cheveronSuffix()}`;
export const ngettext = (...args) =>
  `${cheveronPrefix()}${jed.ngettext(...args)}${cheveronSuffix()}`;

export const { sprintf } = jed;

const i18n = {
  translate,
  ngettext,
  jed,
  sprintf,
  intl,
};
export default i18n;

window.__ = translate;
window.n__ = ngettext;
window.Jed = jed;
window.i18n = jed;

deprecateObjectProperty(window, 'i18n', 'tfm.i18n');
deprecateObjectProperty(window, 'Jed', 'tfm.i18n.jed');
