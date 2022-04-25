import React from 'react';
import { IntlProvider } from 'react-intl';
import { intl } from './I18n';
import { getDisplayName } from './helpers';

const i18nProviderWrapperFactory = (
  initialNow,
  timezone
) => WrappedComponent => {
  const wrappedName = getDisplayName(WrappedComponent);

  const I18nProviderWrapper = props => (  
    <IntlProvider
      locale={intl.locale}
      initialNow={initialNow}
      timeZone={timezone || intl.timezone}
    >
      <WrappedComponent {...props} />
    </IntlProvider>
  );
  I18nProviderWrapper.displayName = `I18nProviderWrapper(${wrappedName})`;

  return I18nProviderWrapper;
};

export { i18nProviderWrapperFactory };
