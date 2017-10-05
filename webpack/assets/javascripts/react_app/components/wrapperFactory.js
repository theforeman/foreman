import React from 'react';
import { Provider } from 'react-redux';
import { intlProviderWrapper } from '../common/i18n';
import helpers from '../common/helpers';

function storeProviderWrapper(store) {
  return (WrappedComponent) => {
    class StoreProvider extends React.Component {
      render() {
        return (
          <Provider store={store}>
            <WrappedComponent {...this.props} />
          </Provider>
        );
      }
    }
    StoreProvider.displayName = `StoreProvider(${helpers.getDisplayName(WrappedComponent)})`;

    return StoreProvider;
  };
}

function dataProviderWrapper(data) {
  return (WrappedComponent) => {
    class DataProvider extends React.Component {
      render() {
        return (
          <WrappedComponent data={data} {...this.props} />
        );
      }
    }
    DataProvider.displayName = `DataProvider(${helpers.getDisplayName(WrappedComponent)})`;

    return DataProvider;
  };
}

function propDataMapperWrapper() {
  return (WrappedComponent) => {
    class PropDataMapper extends React.Component {
      render() {
        return (
          <WrappedComponent data={this.props} />
        );
      }
    }
    PropDataMapper.displayName = `PropDataMapper(${helpers.getDisplayName(WrappedComponent)})`;

    return PropDataMapper;
  };
}

export const wrapperRegistry = {
  wrappers: {
    data: dataProviderWrapper,
    dataMapper: propDataMapperWrapper,
    store: storeProviderWrapper,
    intl: intlProviderWrapper,
  },
  register(name, wrapper) {
    if (this.wrappers[name]) {
      throw new Error(`Wrapper name already taken: ${name}`);
    }

    this.wrappers[name] = wrapper;
  },
  getWrapper(name) {
    if (!this.wrappers[name]) {
      throw new Error(`Wrapper not found: ${name}`);
    }

    return this.wrappers[name];
  },
};

export class WrapperFactory {
  constructor() {
    this.wrapper = component => component;
  }

  with(name, ...params) {
    const previousWrapper = this.wrapper;

    this.wrapper = component =>
      wrapperRegistry.getWrapper(name)(...params)(previousWrapper(component));

    return this;
  }
}
