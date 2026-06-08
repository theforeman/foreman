import React from 'react';
import { render } from '@testing-library/react';
import { Provider } from 'react-redux';
import * as ReactRedux from 'react-redux';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import '@testing-library/jest-dom';
import HostsIndex, { getScheduleJobSearch } from './index';

const mockStore = configureMockStore([thunk]);

// Mock useDispatch
jest.spyOn(ReactRedux, 'useDispatch').mockImplementation(() => jest.fn());

// Mock the API hook to return a controlled response
jest.mock('../PF4/TableIndexPage/Table/TableIndexHooks', () => ({
  useTableIndexAPIResponse: jest.fn(() => ({
    response: {
      results: [
        { id: 1, name: 'host1.example.com' },
        { id: 2, name: 'host2.example.com' },
      ],
      total: 100,
      per_page: 20,
      page: 2, // Simulating page 2 from API
      subtotal: 100,
      message: null,
      search: 'name~host', // Current search query from API
    },
    status: 'RESOLVED',
    setAPIOptions: jest.fn(),
  })),
  useSetParamsAndApiAndSearch: jest.fn(() => ({
    params: {
      search: 'name~host',
      page: 1, // Stale page number in params state
      perPage: 10, // Stale perPage in params state
    },
    setParamsAndAPI: jest.fn(),
  })),
  useCurrentUserTablePreferences: jest.fn(() => ({
    hasPreference: false,
    columns: ['name'], // Array of column names
    currentUserId: 1,
  })),
}));

jest.mock('./Columns/core', () => ({
  __esModule: true,
  default: () => ({
    name: { title: 'Name', wrapper: result => result.name },
  }),
}));

jest.mock('./TableRowActions/core', () => ({
  registerGetActions: jest.fn(),
  getActions: jest.fn(() => []),
}));

jest.mock('../PF4/TableIndexPage/Table/TableHooks', () => ({
  useBulkSelect: jest.fn(() => ({
    fetchBulkParams: jest.fn(),
    searchQuery: '',
    updateSearchQuery: jest.fn(),
    selectAll: jest.fn(),
    selectPage: jest.fn(),
    selectNone: jest.fn(),
    selectedCount: 0,
    selectOne: jest.fn(),
    areAllRowsOnPageSelected: jest.fn(() => false),
    areAllRowsSelected: jest.fn(() => false),
    isSelected: jest.fn(() => false),
    selectedResults: [],
  })),
  useUrlParams: jest.fn(() => ({
    searchParam: 'name~host',
    page: 1,
    per_page: 10,
  })),
}));

jest.mock('../../Root/Context/ForemanContext', () => ({
  useForemanSettings: jest.fn(() => ({
    destroyVmOnHostDelete: false,
  })),
  useForemanHostsPageUrl: jest.fn(() => '/hosts'),
  useForemanContext: jest.fn(() => ({})),
}));

jest.mock('../common/Slot', () => ({
  __esModule: true,
  default: () => null,
}));

jest.mock('../ColumnSelector/helpers', () => ({
  categoriesFromFrontendColumnData: jest.fn(() => []),
  checkColumnRelevancy: jest.fn(() => true),
}));

jest.mock('../ColumnSelector', () => ({
  __esModule: true,
  default: () => null,
}));

jest.mock('../HostDetails/ActionsBar/actions', () => ({
  deleteHost: jest.fn(),
}));

jest.mock('./BulkActions/bulkDelete', () => ({
  bulkDeleteHosts: jest.fn(),
}));

// Mock Table to capture the props it receives
let capturedTableProps = null;
jest.mock('../PF4/TableIndexPage/Table/Table', () => ({
  Table: props => {
    capturedTableProps = props;
    return <div data-testid="mock-table">Table</div>;
  },
}));

jest.mock('../PF4/TableIndexPage/TableIndexPage', () => ({
  __esModule: true,
  default: ({ children }) => <div>{children}</div>,
}));

describe('HostsIndex', () => {
  const store = mockStore({
    foremanModals: {},
    API: {
      HOSTGROUP_KEY: { status: 'RESOLVED', response: { results: [] } },
      BULK_REASSIGN_HOSTGROUP_KEY: { status: undefined },
    },
  });

  beforeEach(() => {
    capturedTableProps = null;
  });

  test('merges API response page and perPage into params passed to Table', () => {
    render(
      <Provider store={store}>
        <HostsIndex />
      </Provider>
    );

    // Verify Table was rendered
    expect(capturedTableProps).not.toBeNull();

    // This is the key test: params should have page=2 and per_page=20 from API response,
    // not page=1 and per_page=10 from stale params state
    expect(capturedTableProps.params).toEqual({
      search: 'name~host',
      page: 2, // From API response, not from params state (which has 1)
      per_page: 20, // From API response, not from params state (which has 10)
    });
  });

  test('returns an explicit all-hosts search for empty select-all queries', () => {
    expect(
      getScheduleJobSearch({
        selectedCount: 100,
        areAllRowsSelected: true,
        selectedHostsSearch: '',
      })
    ).toBe('name ~ *');
  });

  test('does not append the all-hosts fallback to a non-empty select-all search', () => {
    expect(
      getScheduleJobSearch({
        selectedCount: 1,
        areAllRowsSelected: true,
        selectedHostsSearch: 'name = "centos9-katello-devel.example.com"',
      })
    ).toBe('name = "centos9-katello-devel.example.com"');
  });

  test('does not use the all-hosts fallback when select-all is not active', () => {
    expect(
      getScheduleJobSearch({
        selectedCount: 1,
        areAllRowsSelected: false,
        selectedHostsSearch: '',
      })
    ).toBe('');
  });
});
