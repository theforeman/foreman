import API from '../../../API';
import { testActionSnapshotWithFixtures } from '../../../common/testHelpers';
import {
  toggleSwitcher,
  closeSwitcher,
  loadSwitcherResourcesByResource,
} from '../BreadcrumbBarActions';
import {
  resource,
  resourceWithNestedFields,
  serverResourceListResponse,
  serverResourceListWithNestedFieldsResponse,
} from '../BreadcrumbBar.fixtures';

jest.mock('../../../API');

const runLoadSwitcherResourcesByResourceAction = (resourceMock, serverMock) => {
  API.get.mockImplementation(serverMock);

  return loadSwitcherResourcesByResource(resourceMock);
};

const fixtures = {
  'should toggle-switcher': () => toggleSwitcher(),

  'should close-switcher': () => closeSwitcher(),

  'should load-switcher-resources-by-resource and success': () =>
    runLoadSwitcherResourcesByResourceAction(resource, async () => serverResourceListResponse),

  'should load-switcher-resources-by-resource-with-nested-fields and success': () =>
    runLoadSwitcherResourcesByResourceAction(
      resourceWithNestedFields,
      async () => serverResourceListWithNestedFieldsResponse,
    ),

  'should load-switcher-resources-by-resource and fail': () =>
    runLoadSwitcherResourcesByResourceAction(resource, async () => {
      throw new Error('some-error');
    }),
};

describe('BreadcrumbBar actions', () => testActionSnapshotWithFixtures(fixtures));
