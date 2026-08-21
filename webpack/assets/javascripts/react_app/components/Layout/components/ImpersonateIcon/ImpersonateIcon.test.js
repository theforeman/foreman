import React from 'react';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import ImpersonateIcon from './ImpersonateIcon';
import { rtlHelpers } from '../../../../common/rtlTestHelpers';

const { renderWithI18n } = rtlHelpers;

const defaultProps = {
  stopImpersonationUrl: '/stop_impersonation',
  stopImpersonating: jest.fn(),
};

const renderImpersonateIcon = (props = {}) => {
  const stopImpersonating = props.stopImpersonating ?? jest.fn();

  renderWithI18n(
    <ImpersonateIcon
      {...defaultProps}
      {...props}
      stopImpersonating={stopImpersonating}
    />
  );

  return { stopImpersonating };
};

const openImpersonationModal = async () => {
  userEvent.click(
    await screen.findByRole('button', { name: 'Stop impersonation' })
  );

  expect(
    await screen.findByRole('dialog', { name: 'Confirm Action' })
  ).toBeInTheDocument();
};

describe('ImpersonateIcon', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders stop impersonation control', async () => {
    renderImpersonateIcon();

    expect(
      await screen.findByRole('button', { name: 'Stop impersonation' })
    ).toBeInTheDocument();
    expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
  });

  it('opens confirmation modal when stop impersonation is clicked', async () => {
    renderImpersonateIcon();

    await openImpersonationModal();

    expect(
      screen.getByText(
        'You are about to stop impersonating other user. Are you sure?'
      )
    ).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Confirm' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Cancel' })).toBeInTheDocument();
  });

  it('calls stopImpersonating with the url when Confirm is clicked', async () => {
    const { stopImpersonating } = renderImpersonateIcon();

    await openImpersonationModal();
    userEvent.click(screen.getByRole('button', { name: 'Confirm' }));

    expect(stopImpersonating).toHaveBeenCalledWith('/stop_impersonation');
  });

  it('closes the modal when Cancel is clicked', async () => {
    renderImpersonateIcon();

    await openImpersonationModal();
    userEvent.click(screen.getByRole('button', { name: 'Cancel' }));

    await waitFor(() => {
      expect(screen.queryByRole('dialog')).not.toBeInTheDocument();
    });
  });
});
