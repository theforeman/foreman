import React from 'react';
import { IntlProvider } from 'react-intl';
import i18n from './i18n';
import { getDisplayName } from './helpers';

const i18nProviderWrapperFactory = initialNow =>
  (WrappedComponent) => {
    const wrappedName = getDisplayName(WrappedComponent);

    class I18nProviderWrapper extends React.Component {
      constructor(props) {
        super(props);
        this.state = { i18nLoaded: i18n.loaded };

        if (!i18n.loaded) {
          i18n.ready.then(() => {
            this.setState({ i18nLoaded: true });
          });
        }
      }

      render() {
        if (!this.state.i18nLoaded) {
          return <span />;
        }
        return (
          <IntlProvider locale={i18n.locale} initialNow={initialNow}>
            <WrappedComponent {...this.props} />
          </IntlProvider>
        );
      }
    }
    I18nProviderWrapper.displayName = `I18nProviderWrapper(${wrappedName})`;

    return I18nProviderWrapper;
  };

export { i18nProviderWrapperFactory };
