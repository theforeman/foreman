import React from 'react';
import { IntlProvider, addLocaleData } from 'react-intl';
import helpers from './helpers';

const langAttr = document.getElementsByTagName('html')[0].getAttribute('lang') || 'en';

export const locale = langAttr.split('-')[0];
export const timezone = document.getElementsByTagName('html')[0]
  .getAttribute('data-timezone') || 'UTC';

/* eslint-disable global-require, import/no-dynamic-require */
if (!global.Intl) {
  global.Intl = require('intl');
  require(`intl/locale-data/jsonp/${locale}`);
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
