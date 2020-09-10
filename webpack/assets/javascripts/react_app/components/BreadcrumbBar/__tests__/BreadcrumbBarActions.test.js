import { API } from '../../../redux/API';
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

jest.mock('../../../redux/API');

const runLoadSwitcherResourcesByResourceAction = (resourceMock, serverMock) => {
  API.get.mockImplementation(serverMock);

  return loadSwitcherResourcesByResource(resourceMock);
};

const fixtures = {
  'should toggle-switcher': () => toggleSwitcher(),

  'should close-switcher': () => closeSwitcher(),

  'should load-switcher-resources-by-resource and success': () =>
    runLoadSwitcherResourcesByResourceAction(
      resource,
      async () => serverResourceListResponse
    ),

  'should load-switcher-resources-by-resource-with-nested-fields and success': () =>
    runLoadSwitcherResourcesByResourceAction(
      resourceWithNestedFields,
      async () => serverResourceListWithNestedFieldsResponse
    ),

  'should load-switcher-resources-by-resource and fail': () =>
    runLoadSwitcherResourcesByResourceAction(resource, async () => {
      throw new Error('some-error');
    }),
};

describe('BreadcrumbBar actions', () =>
  testActionSnapshotWithFixtures(fixtures));

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
