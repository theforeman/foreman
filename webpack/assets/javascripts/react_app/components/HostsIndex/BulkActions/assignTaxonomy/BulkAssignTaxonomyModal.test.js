import React from 'react';
import { render, screen, fireEvent, act, within } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Provider } from 'react-redux';
import { IntlProvider } from 'react-intl';
import configureMockStore from 'redux-mock-store';
import { STATUS } from '../../../../constants';
import {
  BulkAssignLocationModal,
  BulkAssignOrganizationModal,
} from './BulkAssignTaxonomyModal';

const mockStore = configureMockStore();
const taxonomies = [
  { id: 1, name: 'Lab', title: 'Lab' },
  { id: 2, name: 'Test', title: 'Lab/Test' },
  { id: 3, name: 'Network', title: 'Lab/Test/Network' },
  { id: 4, name: 'Production', title: 'Production' },
  { id: 5, name: 'Test', title: 'Production/Test' },
];

describe.each([
  ['location', BulkAssignLocationModal],
  ['organization', BulkAssignOrganizationModal],
])('Change %s modal', (taxonomy, Component) => {
  const renderModal = () => {
    const store = mockStore({
      API: {
        [taxonomy.toUpperCase()]: {
          status: STATUS.RESOLVED,
          response: { results: taxonomies },
        },
      },
    });
    render(
      <IntlProvider locale="en">
        <Provider store={store}>
          <Component
            isOpen
            selectedCount={1}
            selectAllHostsMode={false}
            fetchBulkParams={() => 'id ^ (42)'}
          />
        </Provider>
      </IntlProvider>
    );
    return store;
  };

  it('shows full paths to distinguish nested taxonomies with the same name', async () => {
    renderModal();
    await act(async () => {
      fireEvent.click(screen.getByRole('button', { name: '' }));
    });

    taxonomies.forEach(({ title }) => {
      expect(screen.getByRole('option', { name: title })).toBeInTheDocument();
    });
    expect(screen.queryByRole('option', { name: 'Test' })).not.toBeInTheDocument();
  });

  it('shows the selected name and submits the correct ID for duplicate child names', async () => {
    const store = renderModal();
    await act(async () => {
      fireEvent.click(screen.getByRole('button', { name: '' }));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole('option', { name: 'Production/Test' }));
    });

    expect(screen.getByRole('button', { name: 'Test' })).toBeInTheDocument();
    fireEvent.click(screen.getByRole('button', { name: `Change ${taxonomy}` }));

    expect(store.getActions()).toContainEqual(
      expect.objectContaining({
        payload: expect.objectContaining({
          url: `/api/v2/hosts/bulk/assign_${taxonomy}`,
          params: {
            id: 5,
            mismatch_setting: true,
            included: { search: 'id ^ (42)' },
          },
        }),
      })
    );
  });

  it('emphasizes the final name and styles ancestors like the host group options', async () => {
    renderModal();
    await act(async () => {
      fireEvent.click(screen.getByRole('button', { name: '' }));
    });

    const rootOption = screen.getByRole('option', { name: 'Lab' });
    expect(
      within(rootOption).getByText('Lab', { selector: 'strong' })
    ).toBeInTheDocument();
    expect(rootOption.querySelector('.taxonomy-name-parent')).toBeNull();

    const nestedOption = screen.getByRole('option', {
      name: 'Lab/Test/Network',
    });
    expect(
      within(nestedOption).getByText('Lab', { selector: '.taxonomy-name-parent' })
    ).toBeInTheDocument();
    expect(
      within(nestedOption).getByText('Test', { selector: '.taxonomy-name-parent' })
    ).toBeInTheDocument();
    expect(
      within(nestedOption).getByText('Network', { selector: 'strong' })
    ).toBeInTheDocument();
  });
});
