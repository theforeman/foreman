import React from 'react';
import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import { rtlHelpers } from '../../../common/rtlTestHelpers';
import { HOST_STATUSES_KEY } from '../HostStatusesConstants';
import { store as hostStatusesStore } from '../HostStatuses.fixtures';
import Status from '.';

const { renderWithStore } = rtlHelpers;

const defaultStatus =
  hostStatusesStore.API[HOST_STATUSES_KEY].response.results[0];

const storeWithStatus = (status = defaultStatus) => ({
  API: {
    [HOST_STATUSES_KEY]: {
      response: {
        results: [status],
      },
    },
  },
});

const renderStatus = (status = defaultStatus) =>
  renderWithStore(<Status name={status.name} />, storeWithStatus(status));

const expandCard = async () => {
  await userEvent.click(screen.getByRole('button', { name: 'Details' }));
};

describe('Status', () => {
  it('renders the status name, description, and count links', () => {
    renderStatus();

    expect(screen.getByText('Status Name')).toBeInTheDocument();
    expect(screen.getByText('Description of the status')).toBeInTheDocument();

    const okTotal = screen.getByRole('link', { name: 'Total: 3' });
    expect(okTotal).toHaveAttribute('href', '/hosts?search=status+%3D+ok');
    const okOwned = screen.getByRole('link', { name: 'Owned: 1' });
    expect(okOwned).toHaveAttribute(
      'href',
      '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+ok'
    );

    const warnTotal = screen.getByRole('link', { name: 'Total: 7' });
    expect(warnTotal).toHaveAttribute('href', '/hosts?search=status+%3D+warn');
    const warnOwned = screen.getByRole('link', { name: 'Owned: 2' });
    expect(warnOwned).toHaveAttribute(
      'href',
      '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+warn'
    );

    const errorTotal = screen.getByRole('link', { name: 'Total: 5' });
    expect(errorTotal).toHaveAttribute(
      'href',
      '/hosts?search=status+%3D+error'
    );
    const errorOwned = screen.getByRole('link', { name: 'Owned: 0' });
    expect(errorOwned).toHaveAttribute(
      'href',
      '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+error'
    );
  });

  it('shows the details table after expanding the card', async () => {
    renderStatus();

    expect(
      screen.queryByRole('grid', { name: 'Host Statuses' })
    ).not.toBeInTheDocument();

    await expandCard();

    const detailsTable = screen.getByRole('grid', { name: 'Host Statuses' });
    expect(detailsTable).toBeInTheDocument();
    expect(within(detailsTable).getByText('OK')).toBeInTheDocument();
    expect(within(detailsTable).getByText('Warning')).toBeInTheDocument();
    expect(within(detailsTable).getByText('Error')).toBeInTheDocument();
    expect(
      within(detailsTable).getByRole('link', { name: '3' })
    ).toHaveAttribute('href', '/hosts?search=status+%3D+ok');
    expect(
      within(detailsTable).getByRole('link', { name: '1' })
    ).toHaveAttribute(
      'href',
      '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+ok'
    );
  });

  it('shows nothing to show when there are no details', async () => {
    const emptyStatus = {
      name: 'Empty Status',
      description: 'Status with no details',
      details: [],
    };

    renderWithStore(<Status name={emptyStatus.name} />, {
      API: {
        [HOST_STATUSES_KEY]: {
          response: {
            results: [defaultStatus, emptyStatus],
          },
        },
      },
    });

    expect(screen.queryByText('Nothing to show')).not.toBeInTheDocument();

    await expandCard();

    expect(screen.getByText('Nothing to show')).toBeInTheDocument();
    expect(
      screen.queryByRole('grid', { name: 'Host Statuses' })
    ).not.toBeInTheDocument();
  });

  it('shows unknown status counts when unknown details are present', async () => {
    renderStatus({
      ...defaultStatus,
      details: [
        ...defaultStatus.details,
        {
          label: 'Unknown',
          global_status: null,
          total: 11,
          owned: 8,
        },
      ],
    });

    expect(screen.getByText('Total: 11')).toBeInTheDocument();
    expect(screen.getByText('Owned: 8')).toBeInTheDocument();
    expect(
      screen.queryByRole('link', { name: 'Total: 11' })
    ).not.toBeInTheDocument();
    expect(
      screen.queryByRole('link', { name: 'Owned: 8' })
    ).not.toBeInTheDocument();
    expect(screen.queryByText('Unknown')).not.toBeInTheDocument();

    await expandCard();

    expect(screen.getByText('Unknown')).toBeInTheDocument();
  });
});
