import Jed from 'jed';
import { addLocaleData } from 'react-intl';
import forceSingleton from './forceSingleton';
import {
  loadVendorIntl,
  loadVendorIntlLocale,
  loadReactIntlLocale,
} from 'vendor-intl';

class IntlLoader {
  constructor(locale, timezone) {
    this.fallbackIntl = !global.Intl;

    [this.locale] = locale.split('-');
    this.timezone = this.fallbackIntl ? 'UTC' : timezone;
    this.ready = this.init();
  }

  async init() {
    await this.fetchIntl();
    const { default: localeData } = await loadReactIntlLocale(this.locale);

    addLocaleData(localeData);
    return true;
  }

  async fetchIntl() {
    if (this.fallbackIntl) {
      const { default: Intl } = await loadVendorIntl();

      global.Intl = Intl;
      await loadVendorIntlLocale(this.locale);
    }
  }
}

const [htmlElemnt] = document.getElementsByTagName('html');
const langAttr = htmlElemnt.getAttribute('lang') || 'en';
const timezoneAttr = htmlElemnt.getAttribute('data-timezone') || 'UTC';

export const intl = forceSingleton(
  'Intl',
  () => new IntlLoader(langAttr, timezoneAttr)
);

const cheveronPrefix = () => (window.I18N_MARK ? '\u00BB' : '');
const cheveronSuffix = () => (window.I18N_MARK ? '\u00AB' : '');

export const documentLocale = () => langAttr;

const getLocaleData = () => {
  const locales = window.locales || {};
  const locale = documentLocale().replace(/-/g, '_');

  if (locales[locale] === undefined) {
    // eslint-disable-next-line no-console
    console.log(
      `could not load translations for ${locale} locale, falling back to default locale.`
    );
    return { domain: 'app', locale_data: { app: { '': {} } } };
  }

  return locales[locale];
};

export const jed = forceSingleton('Jed', () => new Jed(getLocaleData()));

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
