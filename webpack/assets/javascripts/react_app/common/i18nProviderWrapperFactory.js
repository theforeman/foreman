import React from 'react';
import { IntlProvider } from 'react-intl';
import { useSelector } from 'react-redux';
import { intl } from './I18n';
import { getDisplayName } from './helpers';
import { selectI18NReady } from '../ReactApp/ReactAppSelectors';

const i18nProviderWrapperFactory = (
  initialNow,
  timezone
) => WrappedComponent => {
  const wrappedName = getDisplayName(WrappedComponent);

  const I18nProviderWrapper = props => {
    const i18nReady = useSelector(selectI18NReady);
    return (
      i18nReady && (
        <IntlProvider
          locale={intl.locale}
          initialNow={initialNow}
          timeZone={timezone || intl.timezone}
        >
          <WrappedComponent {...props} />
        </IntlProvider>
      )
    );
  };
  I18nProviderWrapper.displayName = `I18nProviderWrapper(${wrappedName})`;

  return I18nProviderWrapper;
};

export { i18nProviderWrapperFactory };
