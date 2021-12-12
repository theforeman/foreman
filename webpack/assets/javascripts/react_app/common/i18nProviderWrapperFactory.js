import React from 'react';
import { IntlProvider } from 'react-intl';
import { intl } from './I18n';
import { getDisplayName } from './helpers';

const i18nProviderWrapperFactory = (
  initialNow,
  timezone
) => WrappedComponent => {
  const wrappedName = getDisplayName(WrappedComponent);

  class I18nProviderWrapper extends React.Component {
    constructor(props) {
      super(props);
      this.state = { i18nLoaded: false };

      // eslint-disable-next-line promise/prefer-await-to-then
      intl.ready.then(() => {
        this.setState({ i18nLoaded: true });
      });
    }

    render() {
      if (!this.state.i18nLoaded) {
        return <span />;
      }
      return (
        <IntlProvider
          locale={intl.locale}
          initialNow={initialNow}
          timeZone={timezone || intl.timezone}
        >
          <WrappedComponent {...this.props} />
        </IntlProvider>
      );
    }
  }
  I18nProviderWrapper.displayName = `I18nProviderWrapper(${wrappedName})`;

  return I18nProviderWrapper;
};

export { i18nProviderWrapperFactory };
