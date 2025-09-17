import React from 'react';
import { render } from '@testing-library/react';
import { Provider } from 'react-redux';
import { createStore, applyMiddleware, compose } from 'redux';
import Immutable from 'seamless-immutable';
import { merge } from 'lodash';
import { i18nProviderWrapperFactory } from './i18nProviderWrapperFactory';
import reducers from '../redux/reducers';
import { middlewares } from '../redux/middlewares';
import { initMockStore } from './testInitialReduxStore';

export const createTestStore = (
  initialState = {},
  storeConfig = compose(applyMiddleware(...middlewares))
) =>
  createStore(
    reducers,
    Immutable(merge(initMockStore, initialState)),
    storeConfig
  );

export const rtlHelpers = {
  /**
   * Utility for rendering components that need Redux store
   * @param {ReactElement} component - Component to render
   * @param {Object} initialState - Initial Redux state, defaults to initMockStore from testHelpers.js
   * @param {Object} storeConfig - Additional store configuration, defaults to foreman Redux setup
   * @returns {Object} RTL render result with store
   */
  renderWithStore: (component, initialState, storeConfig) => {
    const store = createTestStore(initialState, storeConfig);
    return {
      ...render(<Provider store={store}>{component}</Provider>),
      store,
    };
  },

  /**
   * Utility for rendering components that need i18n context
   * @param {ReactElement} component - Component to render
   * @param {Date} mockDate - Mock date for time-based components
   * @param {string} timezone - Timezone for date formatting
   * @returns {Object} RTL render result
   */
  renderWithI18n: (component, mockDate = new Date(), timezone = 'UTC') => {
    const IntlWrapper = i18nProviderWrapperFactory(mockDate, timezone);
    return render(React.createElement(IntlWrapper, {}, component));
  },

  /**
   * Utility for rendering components that need both Redux and i18n
   * @param {ReactElement} component - Component to render
   * @param {Object} initialState - Initial Redux state
   * @param {Date} mockDate - Mock date for time-based components
   * @param {string} timezone - Timezone for date formatting
   * @returns {Object} RTL render result with store
   */
  renderWithStoreAndI18n: (
    component,
    initialState = {},
    mockDate = new Date(),
    timezone = 'UTC'
  ) => {
    const store = createTestStore(initialState);
    const IntlWrapper = i18nProviderWrapperFactory(mockDate, timezone);

    return {
      ...render(
        <Provider store={store}>
          {React.createElement(IntlWrapper, {}, component)}
        </Provider>
      ),
      store,
    };
  },

  /**
   * Common assertions for form components
   */
  formAssertions: {
    expectSubmitButton: screen =>
      expect(
        screen.getByRole('button', { name: /submit/i })
      ).toBeInTheDocument(),

    expectCancelButton: screen =>
      expect(
        screen.getByRole('button', { name: /cancel/i })
      ).toBeInTheDocument(),

    expectErrorAlert: (screen, errorText) => {
      expect(screen.getByRole('alert')).toBeInTheDocument();
      if (errorText) {
        expect(screen.getByText(errorText)).toBeInTheDocument();
      }
    },

    expectErrorList: (screen, errorMessages) => {
      expect(screen.getByRole('alert')).toBeInTheDocument();
      const listItems = screen.getAllByRole('listitem');
      expect(listItems).toHaveLength(errorMessages.length);
      errorMessages.forEach(message => {
        expect(screen.getByText(message)).toBeInTheDocument();
      });
    },

    expectWarningAlert: (screen, warningText) => {
      const alert = screen.getByRole('alert');
      expect(alert).toBeInTheDocument();
      // PatternFly alerts with warning severity should have appropriate styling
      if (warningText) {
        expect(screen.getByText(warningText)).toBeInTheDocument();
      }
    },
  },

  /**
   * Common assertions for table components
   */
  tableAssertions: {
    expectColumnHeaders: (screen, columnNames) => {
      columnNames.forEach(columnName => {
        expect(screen.getByText(columnName)).toBeInTheDocument();
      });
    },

    expectRowData: (screen, rowData) => {
      rowData.forEach(data => {
        expect(screen.getByText(data)).toBeInTheDocument();
      });
    },

    expectSortableColumn: (screen, columnName) => {
      expect(
        screen.getByRole('button', { name: columnName })
      ).toBeInTheDocument();
    },

    expectActionMenu: screen => {
      expect(screen.getByLabelText('Kebab toggle')).toBeInTheDocument();
    },
  },

  /**
   * Common assertions for date/time components
   */
  dateTimeAssertions: {
    expectFormattedDate: (screen, expectedFormat) => {
      expect(screen.getByText(expectedFormat)).toBeInTheDocument();
    },

    expectTooltip: (screen, tooltipText) => {
      // For components with tooltips, we might need to hover or check aria-describedby
      expect(screen.getByText(tooltipText)).toBeInTheDocument();
    },

    expectDefaultValue: (screen, defaultValue) => {
      expect(screen.getByText(defaultValue)).toBeInTheDocument();
    },
  },

  /**
   * Helper to create mock props for common component patterns
   */
  createMockProps: {
    tableData: (columns, results) => ({
      columns,
      results,
      params: { page: 1, perPage: 10, order: '' },
      setParams: jest.fn(),
      refreshData: jest.fn(),
      url: '/test',
      isPending: false,
    }),

    dateTimeProps: (date = new Date('2017-10-13 00:54:55 -1100')) => ({
      date,
      defaultValue: 'Default value',
    }),
  },

  /**
   * Mock functions commonly used in tests
   */
  mockFunctions: {
    onSubmit: jest.fn(),
    onCancel: jest.fn(),
    onClick: jest.fn(),
    onChange: jest.fn(),
    onDeleteClick: jest.fn(),
    setParams: jest.fn(),
    refreshData: jest.fn(),
  },

  /**
   * Helper to wait for async operations in tests
   */
  waitForAsync: async (callback, timeout = 1000) =>
    new Promise(resolve =>
      setTimeout(() => {
        callback();
        resolve();
      }, timeout)
    ),
};
