import React from 'react';
import { IntlProvider, addLocaleData } from 'react-intl';
import helpers from './helpers';

const langAttr = document.getElementsByTagName('html')[0].getAttribute('lang') || 'en';

export const locale = langAttr.split('-')[0];
export const timezone = document.getElementsByTagName('html')[0]
  .getAttribute('data-timezone') || 'UTC';

/* eslint-disable global-require, import/no-dynamic-require */
async function fetchIntl(intlLocale) {
  global.Intl = await import(/* webpackChunkName: "intl-fallback", webpackMode: "lazy" */ 'intl');
  await import(/* webpackChunkName: "intl-fallback", webpackMode: "lazy" */ `intl/locale-data/jsonp/${intlLocale}`);
}

if (!global.Intl) {
  fetchIntl(locale);
}
addLocaleData(require(`react-intl/locale-data/${locale}`));
/* eslint-enable global-require, import/no-dynamic-require */

export function intlProviderWrapper(initialNow = undefined) {
  return (WrappedComponent) => {
    const wrappedName = helpers.getDisplayName(WrappedComponent);

    class IntlProviderWrapper extends React.Component {
      render() {
        return (
          <IntlProvider locale={locale} initialNow={initialNow}>
            <WrappedComponent {...this.props} />
          </IntlProvider>
        );
      }
    }
    IntlProviderWrapper.displayName = `IntlProviderWrapper(${wrappedName})`;

    return IntlProviderWrapper;
  };
}
