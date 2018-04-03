import API from '../../../API';
import {
  toggleSwitcher,
  closeSwitcher,
  loadSwitcherResourcesByResource,
} from '../BreadcrumbBarActions';
import { resource, serverResourceListResponse } from '../BreadcrumbBar.fixtures';

jest.mock('../../../API');

describe('BreadcrumbBar actions', () => {
  it('should toggle-switcher', () => expect(toggleSwitcher()).toMatchSnapshot());

  it('should close-switcher', () => expect(closeSwitcher()).toMatchSnapshot());

  it('should load-switcher-resources-by-resource and success', async () => {
    API.get.mockImplementation(async () => serverResourceListResponse);

    const dispatch = jest.fn();
    const dispatcher = loadSwitcherResourcesByResource(resource);

    await dispatcher(dispatch);

    expect(dispatch.mock.calls).toMatchSnapshot();
  });

  it('should load-switcher-resources-by-resource and fail', async () => {
    API.get.mockImplementation(async () => {
      throw new Error('some-error');
    });

    const dispatch = jest.fn();
    const dispatcher = loadSwitcherResourcesByResource(resource);

    await dispatcher(dispatch);

    expect(dispatch.mock.calls).toMatchSnapshot();
  });
});
