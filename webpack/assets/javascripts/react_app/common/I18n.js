/* eslint-disable global-require */
/* eslint-disable import/no-dynamic-require */
import Jed from 'jed';
import { addLocaleData } from 'react-intl';
import Cookies from 'js-cookie';
import jstz from 'jstz';
import forceSingleton from './forceSingleton';

class IntlLoader {
  constructor(locale, timezone) {
    this.fallbackIntl = !global.Intl;

    // eslint-disable-next-line prefer-destructuring
    this.locale = locale.split('-')[0];
    this.timezone = this.fallbackIntl ? 'UTC' : timezone;
    this.ready = this.init();
  }

  async init() {
    await this.fetchIntl();
    const localeData = require(/* webpackChunkName: 'react-intl/locale/[request]' */ `react-intl/locale-data/${this.locale}`);
    addLocaleData(localeData);
    Cookies.set('timezone', jstz.determine().name(), {
      path: '/',
      secure: window.location.protocol === 'https:',
    });
    return true;
  }

  fetchIntl() {
    if (this.fallbackIntl) {
      global.Intl = require(/* webpackChunkName: "intl" */ 'intl');
      require(/* webpackChunkName: 'intl/locale/[request]' */ `intl/locale-data/jsonp/${this.locale}`);
    }
  }
}

const htmlElemnt = document.getElementsByTagName('html')[0];
const langAttr = htmlElemnt.getAttribute('lang') || 'en';
const timezoneAttr = htmlElemnt.getAttribute('data-timezone') || 'UTC';

export const intl = forceSingleton(
  'Intl',
  () => new IntlLoader(langAttr, timezoneAttr)
);

const cheveronPrefix = () => (window.I18N_MARK ? '\u00BB' : '');
const cheveronSuffix = () => (window.I18N_MARK ? '\u00AB' : '');

export const documentLocale = () => langAttr;

const unwrapLocaleDomains = (locales, locale) => {
  const result = locales[locale];
  Object.entries(locales).forEach(([key, localeData]) => {
    if (locale in localeData && 'domain' in localeData[locale]) {
      result.locale_data[key] = localeData[locale].locale_data[key];
    }
  });
  return result;
};

const mergeLocaleData = locale => {
  const result = {};
  Object.entries(locale.locale_data).forEach(([domain, translations]) => {
    Object.entries(translations).forEach(([source, translated]) => {
      if (
        result[source] === undefined ||
        (result[source]?.[0]?.length === 0 && !translated[0]?.length === 0)
      ) {
        result[source] = translated;
      }
    });
  });
  return result;
};

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

  const unwrapped = unwrapLocaleDomains(locales, locale);
  unwrapped.locale_data = {
    ...unwrapped.locale_data,
    app: mergeLocaleData(unwrapped),
  };
  return unwrapped;
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
