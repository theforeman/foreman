import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import { Provider } from 'react-redux';
import configureMockStore from 'redux-mock-store';
import thunk from 'redux-thunk';
import BulkPowerStateModal from './BulkPowerStateModal';
import { HostsPowerRefreshContext } from '../../HostsPowerRefreshContext';
import { bulkChangePowerState } from './actions';

jest.mock('../../../../common/I18n');
jest.mock('./actions');

const mockStore = configureMockStore([thunk]);

const defaultProps = {
  selectedHostsCount: 3,
  fetchBulkParams: jest.fn(() => 'id ^ (1,2,3)'),
  isOpen: true,
  closeModal: jest.fn(),
};

const renderModal = (props = {}) => {
  const store = mockStore({ API: {} });
  render(
    <Provider store={store}>
      <HostsPowerRefreshContext.Provider value={{ bumpRefresh: jest.fn() }}>
        <BulkPowerStateModal {...defaultProps} {...props} />
      </HostsPowerRefreshContext.Provider>
    </Provider>
  );
  return store;
};

describe('BulkPowerStateModal', () => {
  let capturedHandleError;

  beforeEach(() => {
    jest.clearAllMocks();
    bulkChangePowerState.mockImplementation(
      (_payload, _handleSuccess, handleError) => {
        capturedHandleError = handleError;
        return { type: 'MOCK_ACTION' };
      }
    );
  });

  const selectAndSubmit = async () => {
    await act(async () => {
      fireEvent.click(screen.getByText('Select power state'));
    });
    await act(async () => {
      fireEvent.click(screen.getByText('Start'));
    });
    await act(async () => {
      fireEvent.click(screen.getByRole('button', { name: /apply/i }));
    });
  };

  it('renders modal with title and power state select', () => {
    renderModal();
    expect(screen.getByText('Change power state')).toBeInTheDocument();
    expect(screen.getByText('Select power state')).toBeInTheDocument();
  });

  it('has Apply disabled until a power state is selected', async () => {
    renderModal();
    expect(screen.getByRole('button', { name: /apply/i })).toBeDisabled();
    await act(async () => {
      fireEvent.click(screen.getByText('Select power state'));
    });
    await act(async () => {
      fireEvent.click(screen.getByText('Start'));
    });
    expect(screen.getByRole('button', { name: /apply/i })).not.toBeDisabled();
  });

  it('calls closeModal on Cancel', async () => {
    const closeModal = jest.fn();
    renderModal({ closeModal });
    await act(async () => {
      fireEvent.click(screen.getByRole('button', { name: /cancel/i }));
    });
    expect(closeModal).toHaveBeenCalled();
  });

  describe('handleError', () => {
    it('shows object error as danger toast with failed hosts link', async () => {
      const store = renderModal();
      await selectAndSubmit();

      await act(async () => {
        capturedHandleError({
          response: {
            data: {
              error: { message: 'Some hosts failed', failed_host_ids: [1, 2] },
            },
          },
        });
      });

      const toast = store
        .getActions()
        .find(a => a.type === 'toasts/addToast')?.payload.toast;
      expect(toast).toMatchObject({ type: 'danger', message: 'Some hosts failed' });
      expect(toast.link).toBeDefined();
    });

    it('enriches message with provider errors from failed_hosts', async () => {
      const store = renderModal();
      await selectAndSubmit();

      await act(async () => {
        capturedHandleError({
          response: {
            data: {
              error: {
                message: 'Partial failure.',
                failed_hosts: [
                  { id: 1, error: 'Provider A failed' },
                  { id: 2, error: 'Provider B failed' },
                ],
              },
            },
          },
        });
      });

      const toast = store
        .getActions()
        .find(a => a.type === 'toasts/addToast')?.payload.toast;
      expect(toast.type).toBe('danger');
      expect(toast.message).toContain('Partial failure.');
      expect(toast.message).toContain('Provider A failed');
      expect(toast.message).toContain('Provider B failed');
    });

    it('handles a string apiError correctly without a link', async () => {
      // regression: old code spread a string into failedHostsToastParams,
      // losing the message entirely — the isObject guard fixes this
      const store = renderModal();
      await selectAndSubmit();

      await act(async () => {
        capturedHandleError({
          response: { data: { error: 'Something went wrong' } },
        });
      });

      const toast = store
        .getActions()
        .find(a => a.type === 'toasts/addToast')?.payload.toast;
      expect(toast).toMatchObject({ type: 'danger', message: 'Something went wrong' });
      expect(toast.link).toBeUndefined();
    });

    it('falls back to error.message for network errors without a response', async () => {
      const store = renderModal();
      await selectAndSubmit();

      await act(async () => {
        capturedHandleError({ message: 'Network Error' });
      });

      const toast = store
        .getActions()
        .find(a => a.type === 'toasts/addToast')?.payload.toast;
      expect(toast).toMatchObject({ type: 'danger', message: 'Network Error' });
      expect(toast.link).toBeUndefined();
    });
  });
});
