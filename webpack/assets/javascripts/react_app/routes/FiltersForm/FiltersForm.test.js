import React from 'react';
import {
  render,
  fireEvent,
  screen,
  waitFor,
  act,
} from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import { FiltersForm } from './FiltersForm';
import { Provider } from 'react-redux';
import store from '../../redux';

const props = { history: { push: jest.fn() } };

const newProps = {
  isNew: true,
  roleName: 'test role for new',
  roleId: 56,
  data: {},
  ...props,
};
const editProps = {
  isNew: false,
  roleName: 'test role for edit',
  roleId: 45,
  data: {
    search: 'os = CentOS',
    resource_type_label: 'Host',
    'unlimited?': true,
    created_at: '2022-04-06 14:26:22 +0200',
    updated_at: '2022-04-06 14:26:22 +0200',
    'override?': true,
    id: 567,
    resource_type: 'Host',
    role: {
      name: 'test',
      id: 45,
      description: '',
      origin: null,
    },
    permissions: [
      {
        name: 'view_hosts',
        id: 51,
        resource_type: 'Host',
      },
      {
        name: 'edit_hosts',
        id: 53,
        resource_type: 'Host',
      },
    ],
    locations: [
      {
        id: 21,
        name: 'test',
        title: 'test',
        description: '',
      },
    ],
    organizations: [
      {
        id: 12,
        name: 'craig-bemis',
        title: 'craig-bemis',
        description: null,
      },
      {
        id: 19,
        name: 'ddw',
        title: 'ddw',
        description: '',
      },
    ],
  },
  ...props,
};

jest.mock('../../redux/API/API', () => ({
  get: async url => {
    if (url === '/api/v2/roles?per_page=all') {
      return {
        data: {
          total: 3,
          subtotal: 3,
          page: 1,
          per_page: 3,
          search: null,
          results: [
            {
              name: 'test role for edit',
              id: 45,
            },
            {
              name: 'test role for new',
              id: 56,
            },
            {
              name: 'Default role',
              id: 34,
            },
          ],
        },
      };
    }
    if (url === '/permissions/show_resource_types_with_translations') {
      return {
        data: {
          resource_types: [
            {
              translation: '_AuthSource_',
              name: 'AuthSource',
              granular: true,
              search_path: '/auth_sources/auto_complete_search',
              show_organizations: true,
              show_locations: true,
            },
            {
              translation: '_Bookmark_',
              name: 'Bookmark',
              granular: true,
              search_path: '/bookmarks/auto_complete_search',
              show_organizations: false,
              show_locations: false,
            },
            {
              translation: '_ComputeProfile_',
              name: 'ComputeProfile',
              granular: true,
              search_path: '/compute_profiles/auto_complete_search',
              show_organizations: false,
              show_locations: false,
            },
            {
              translation: '_Host_',
              name: 'Host',
              granular: true,
              search_path: '/hosts/auto_complete_search',
              show_organizations: true,
              show_locations: true,
            },
          ],
        },
      };
    }
    if (url === '/api/v2/permissions?per_page=all&search=resource_type=Host') {
      return {
        data: {
          total: 159,
          subtotal: 9,
          page: 1,
          per_page: 159,
          search: 'resource_type=Host',
          sort: {
            by: null,
            order: null,
          },
          results: [
            { name: 'view_hosts', id: 51, resource_type: 'Host' },
            { name: 'create_hosts', id: 52, resource_type: 'Host' },
            { name: 'edit_hosts', id: 53, resource_type: 'Host' },
            { name: 'destroy_hosts', id: 54, resource_type: 'Host' },
            { name: 'build_hosts', id: 55, resource_type: 'Host' },
            { name: 'power_hosts', id: 56, resource_type: 'Host' },
            { name: 'console_hosts', id: 57, resource_type: 'Host' },
            { name: 'ipmi_boot_hosts', id: 58, resource_type: 'Host' },
            { name: 'forget_status_hosts', id: 59, resource_type: 'Host' },
          ],
        },
      };
    }
    if (
      url === '/api/v2/permissions?per_page=all&search=null?%20resource_type'
    ) {
      return {
        data: {
          total: 159,
          subtotal: 4,
          page: 1,
          per_page: 159,
          search: 'null? resource_type',
          sort: {
            by: null,
            order: null,
          },
          results: [
            { name: 'access_dashboard', id: 32, resource_type: null },
            { name: 'view_plugins', id: 118, resource_type: null },
            { name: 'escalate_roles', id: 127, resource_type: null },
            { name: 'view_statuses', id: 156, resource_type: null },
          ],
        },
      };
    }
  },
}));

const responseTypeLabel = 'Select a resource type';
const roleLabel = 'Select a role';

describe('FiltersForm', () => {
  it('edit', async () => {
    render(
      <Provider store={store}>
        <FiltersForm {...editProps} />
      </Provider>
    );

    await waitFor(() => screen.getByDisplayValue('test role for edit'));
    expect(screen.getByLabelText(roleLabel).value).toBe(editProps.roleName);
    expect(screen.getByLabelText(responseTypeLabel).value).toBe('_Host_');
    expect(screen.queryAllByText('access_dashboard')).toHaveLength(0);
    expect(screen.queryAllByText('view_hosts')).toHaveLength(1);
    expect(screen.queryAllByDisplayValue('os = CentOS')).toHaveLength(1);
    expect(screen.queryAllByText('Override?')).toHaveLength(1);
    expect(screen.queryAllByText('Unlimited?')).toHaveLength(1);
    expect(screen.queryAllByText('0 of 7 items selected')).toHaveLength(1); // unselected permissions
    expect(screen.queryAllByText('0 of 2 items selected')).toHaveLength(1); // selected permissions
  });
  it('new', async () => {
    render(
      <Provider store={store}>
        <FiltersForm {...newProps} />
      </Provider>
    );

    await waitFor(() => screen.getByText('test role for new'));
    expect(screen.getByLabelText(responseTypeLabel).value).toBe(
      '(Miscellaneous)'
    );
    expect(screen.queryAllByText('access_dashboard')).toHaveLength(1);
    expect(screen.queryAllByText('view_hosts')).toHaveLength(0);
    expect(screen.queryAllByText('Override?')).toHaveLength(0);
    expect(screen.queryAllByText('Unlimited?')).toHaveLength(0);
    act(() => {
      fireEvent.click(screen.getByLabelText('resource type toggle'));
    });
    await act(async () => {
      fireEvent.click(screen.getByText('_Host_'));
    });
    
    expect(screen.queryAllByText('access_dashboard')).toHaveLength(0);
    expect(screen.queryAllByText('view_hosts')).toHaveLength(1);
    expect(screen.queryAllByText('Override?')).toHaveLength(1);
    expect(screen.queryAllByText('Unlimited?')).toHaveLength(1);
    expect(screen.getByPlaceholderText('Search')).not.toBeDisabled();
    act(() => {
      fireEvent.click(screen.getByLabelText('is unlimited'));
    });
    expect(screen.getByPlaceholderText('Search')).toBeDisabled();

    expect(screen.queryAllByText('Organizations')).toHaveLength(0);
    expect(screen.queryAllByText('Locations')).toHaveLength(0);
    await act(async() => {
      fireEvent.click(screen.getByLabelText('is override'));
    });
    expect(screen.queryAllByText('Organizations')).toHaveLength(1);
    expect(screen.queryAllByText('Locations')).toHaveLength(1);
  });
});
