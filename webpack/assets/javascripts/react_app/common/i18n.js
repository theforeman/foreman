import { addLocaleData } from 'react-intl';

const runningInPhantomJS = () => (window._phantom !== undefined);

class I18n {
  constructor(locale, timezone) {
    this.fallbackIntl = !global.Intl || runningInPhantomJS();

    [this.locale] = locale.split('-');
    this.timezone = this.fallbackIntl ? 'UTC' : timezone;
    this.loaded = false;
    this.ready = this.init();
  }

  async init() {
    await this.fetchIntl();
    addLocaleData(await import(/* webpackChunkName: 'react-intl/locale/[request]' */`react-intl/locale-data/${this.locale}`));
    this.loaded = true;
  }

  async fetchIntl() {
    if (this.fallbackIntl) {
      global.Intl = await import(/* webpackChunkName: "intl" */ 'intl');
      await import(/* webpackChunkName: 'intl/locale/[request]' */ `intl/locale-data/jsonp/${this.locale}`);
    }
  }
}

const [htmlElemnt] = document.getElementsByTagName('html');
const langAttr = htmlElemnt.getAttribute('lang') || 'en';
const timezoneAttr = htmlElemnt.getAttribute('data-timezone') || 'UTC';

const i18n = new I18n(langAttr, timezoneAttr);

export default i18n;
