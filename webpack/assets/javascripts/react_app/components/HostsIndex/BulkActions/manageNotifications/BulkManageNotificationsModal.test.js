import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Provider } from 'react-redux';
import { IntlProvider } from 'react-intl';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import BulkManageNotificationsModal from './BulkManageNotificationsModal';

jest.mock('../../../../common/I18n');

const mockStore = configureMockStore([thunk]);
const store = mockStore({ API: {} });

const defaultProps = {
  selectedCount: 5,
  fetchBulkParams: jest.fn(() => 'id ^ (1,2,3,4,5)'),
  isOpen: true,
  closeModal: jest.fn(),
};

const renderModal = (props = {}) =>
  render(
    <IntlProvider locale="en">
      <Provider store={store}>
        <BulkManageNotificationsModal {...defaultProps} {...props} />
      </Provider>
    </IntlProvider>
  );

describe('BulkManageNotificationsModal', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    store.clearActions();
  });

  it('renders modal with title and toggle group', () => {
    renderModal();
    expect(screen.getByText('Manage notifications')).toBeInTheDocument();
    expect(screen.getByText('Enable')).toBeInTheDocument();
    expect(screen.getByText('Disable')).toBeInTheDocument();
  });

  it('displays host count in description', () => {
    renderModal();
    const description = document.querySelector('[data-ouia-component-id="manage-notifications-hosts-count"]');
    expect(description).toBeInTheDocument();
    expect(description.textContent).toBe('Enable or disable email notification alerts for 5 selected hosts.');
  });

  it('uses singular form for single host', () => {
    renderModal({ selectedCount: 1 });
    const description = document.querySelector('[data-ouia-component-id="manage-notifications-hosts-count"]');
    expect(description).toBeInTheDocument();
    expect(description.textContent).toBe('Enable or disable email notification alerts for 1 selected host.');
  });

  it('has Confirm disabled by default until a selection is made', () => {
    renderModal();
    const confirmBtn = screen.getByText('Confirm').closest('button');
    expect(confirmBtn).toBeDisabled();

    fireEvent.click(screen.getByText('Enable'));
    expect(confirmBtn).not.toBeDisabled();
  });

  it('calls closeModal on Cancel', () => {
    const closeModal = jest.fn();
    renderModal({ closeModal });

    fireEvent.click(screen.getByText('Cancel'));
    expect(closeModal).toHaveBeenCalled();
  });

  it('dispatches action on Confirm', () => {
    renderModal();

    fireEvent.click(screen.getByText('Enable'));
    fireEvent.click(screen.getByText('Confirm'));
    const actions = store.getActions();
    expect(actions.length).toBeGreaterThan(0);
  });

  it('does not render when isOpen is false', () => {
    renderModal({ isOpen: false });
    expect(screen.queryByText('Manage notifications')).not.toBeInTheDocument();
  });
});
