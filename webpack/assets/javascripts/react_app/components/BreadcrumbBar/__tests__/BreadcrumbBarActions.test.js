import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import API from '../../../redux/API/API';
import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  toggleSwitcher,
  closeSwitcher,
  loadSwitcherResourcesByResource,
  createSearch,
} from '../BreadcrumbBarActions';
import {
  resource,
  resourceWithNestedFields,
  serverResourceListResponse,
  serverResourceListWithNestedFieldsResponse,
} from '../BreadcrumbBar.fixtures';

import { APIMiddleware } from '../../../redux/API';
import IntegrationTestHelper from '../../../common/IntegrationTestHelper';

jest.mock('../../../redux/API/API');
const middlewares = [thunk, APIMiddleware];
const mockStore = configureMockStore(middlewares);
const store = mockStore();

afterEach(() => {
  store.clearActions();
});

const fixtures = {
  'should toggle-switcher': () => toggleSwitcher(),

  'should close-switcher': () => closeSwitcher(),
};

describe('BreadcrumbBar actions', () => {
  testActionSnapshotWithFixtures(fixtures);
  it('should load-switcher-resources-by-resource and success', async () => {
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          resolve(serverResourceListResponse);
        })
    );
    await store.dispatch(loadSwitcherResourcesByResource(resource));
    await IntegrationTestHelper.flushAllPromises();
    expect(store.getActions()).toMatchSnapshot();
  });
  it('should load-switcher-resources-by-resource-with-nested-fields and success', async () => {
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          resolve(serverResourceListWithNestedFieldsResponse);
        })
    );
    await store.dispatch(
      loadSwitcherResourcesByResource(resourceWithNestedFields)
    );
    await IntegrationTestHelper.flushAllPromises();
    expect(store.getActions()).toMatchSnapshot();
  });
  it('should load-switcher-resources-by-resource and fail', async () => {
    API.get.mockImplementation(
      () =>
        new Promise((resolve, reject) => {
          reject(Error('some-error'));
        })
    );
    await store.dispatch(loadSwitcherResourcesByResource(resource));
    await IntegrationTestHelper.flushAllPromises();
    expect(store.getActions()).toMatchSnapshot();
  });
});

describe('createSearch', () => {
  it('should add filter to query', () => {
    const res = createSearch('name', 'aaa', 'god_object = true');
    expect(res).toEqual('god_object = true AND name~aaa');
  });

  it('should not add AND when filter not present', () => {
    const res = createSearch('name', 'bbb', '');
    expect(res).toEqual('name~bbb');
  });

  it('should not add AND when searchQuery not present', () => {
    const res = createSearch('name', '', 'time_for_tea = true');
    expect(res).toEqual('time_for_tea = true');
  });

  it('should return empty string when filter and searchQuery absent', () => {
    const res = createSearch('name', '', '');
    expect(res).toEqual('');
  });
});
