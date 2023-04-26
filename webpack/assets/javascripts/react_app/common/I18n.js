import Jed from 'jed';
import { addLocaleData } from 'react-intl';
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
    const localeData = await import(
      /* webpackChunkName: 'react-intl/locale/[request]' */ `react-intl/locale-data/${this.locale}`
    );
    addLocaleData(localeData.default);
    return true;
  }

  async fetchIntl() {
    if (this.fallbackIntl) {
      global.Intl = await import(/* webpackChunkName: "intl" */ 'intl');
      await import(
        /* webpackChunkName: 'intl/locale/[request]' */ `intl/locale-data/jsonp/${this.locale}`
      );
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
  return unwrapLocaleDomains(locales, locale);
};

export const jed = forceSingleton('Jed', () => new Jed(getLocaleData()));

export const strictJed = forceSingleton('strictJed', () => {
  const options = {
    ...jed.options,
    missing_key_callback: (_key, _domain) => {
      throw new Error('Key not found');
    },
  };
  return new Jed(options);
});

const multidomain = (strict, fallback) => (...args) => {
  // eslint-disable-next-line no-unused-vars
  for (const domain of Object.keys(strictJed.options.locale_data)) {
    try {
      return strictJed[strict](domain, ...args);
    } catch {} // eslint-disable-line no-empty
  }
  return jed[fallback](...args);
};

export const multidomainTranslate = multidomain('dgettext', 'gettext');

export const multidomainngettext = multidomain('dngettext', 'ngettext');

export const translate = (...args) =>
  `${cheveronPrefix()}${multidomainTranslate(...args)}${cheveronSuffix()}`;
export const ngettext = (...args) =>
  `${cheveronPrefix()}${multidomainngettext(...args)}${cheveronSuffix()}`;

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
