import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import Status from '../Status';
import { HOST_STATUSES_KEY } from '../HostStatusesConstants';
import { store } from '../HostStatuses.fixtures.js'

jest.mock('react-redux', () => ({
  ...jest.requireActual('react-redux'),
  useSelector: jest.fn().mockImplementation(selector => selector()),
}));

jest.mock('../HostStatusesSelectors.js', () => {
  const { get } = require('lodash');
  const { HOST_STATUSES_KEY } = require('../HostStatusesConstants')
  const { store } = require('../HostStatuses.fixtures.js');

  const status = get(store, ['API', HOST_STATUSES_KEY, 'response', 'results', '0'])
  const details = get(status, 'details')

  return {
    selectGlobalStatus: jest.fn().mockReturnValue(2),
    selectHostStatusDetails: jest.fn().mockReturnValue(details),
    selectHostStatusDescription: jest.fn().mockReturnValue(get(status, 'description')),
    selectHostStatusTotalPaths: jest.fn().mockReturnValue({
      okTotalPath: get(status, 'ok_total_path'),
      warnTotalPath: get(status, 'warn_total_path'),
      errorTotalPath: get(status, 'error_total_path'),
    }),
    selectHostStatusOwnedPaths: jest.fn().mockReturnValue({
      okOwnedPath: get(status, 'ok_owned_path'),
      warnOwnedPath: get(status, 'warn_owned_path'),
      errorOwnedPath: get(status, 'error_owned_path'),
    }),
    selectHostStatusCounter: jest.fn().mockReturnValue({
      ok: {
        "owned": details.filter(({ global_status: gs }) => gs == 0).map(({ owned }) => owned).reduce((a, b) => a + b),
        "total": details.filter(({ global_status: gs }) => gs == 0).map(({ total }) => total).reduce((a, b) => a + b),
      },
      warn: {
        "owned": details.filter(({ global_status: gs }) => gs == 1).map(({ owned }) => owned).reduce((a, b) => a + b),
        "total": details.filter(({ global_status: gs }) => gs == 1).map(({ total }) => total).reduce((a, b) => a + b),
      },
      error: {
        "owned": details.filter(({ global_status: gs }) => gs == 2).map(({ owned }) => owned).reduce((a, b) => a + b),
        "total": details.filter(({ global_status: gs }) => gs == 2).map(({ total }) => total).reduce((a, b) => a + b),
      },
      unknown: {
        "owned": details.filter(({ global_status: gs }) => gs == null).map(({ owned }) => owned).reduce((a, b) => (a + b), 0),
        "total": details.filter(({ global_status: gs }) => gs == null).map(({ total }) => total).reduce((a, b) => (a + b), 0),
      },
    }),
  }
});

const { name } = store.API[HOST_STATUSES_KEY].response.results[0];

describe('Status', () => {
  it('renders Status', () => {
    render(<Status name={name} />);

    // status name and description
    expect(screen.getByText('Status Name')).toBeInTheDocument();
    expect(screen.getByText('Description of the status')).toBeInTheDocument();

    // ok/warn/error totals and owned counts
    expect(screen.getByText('Total: 3')).toBeInTheDocument();
    expect(screen.getByText('Owned: 1')).toBeInTheDocument();
    expect(screen.getByText('Total: 7')).toBeInTheDocument();
    expect(screen.getByText('Owned: 2')).toBeInTheDocument();
    expect(screen.getByText('Total: 5')).toBeInTheDocument();
    expect(screen.getByText('Owned: 0')).toBeInTheDocument();

    // totals link to their status searches
    expect(screen.getByRole('link', { name: 'Total: 3' })).toHaveAttribute(
      'href',
      '/hosts?search=status+%3D+ok'
    );
    expect(screen.getByRole('link', { name: 'Total: 7' })).toHaveAttribute(
      'href',
      '/hosts?search=status+%3D+warn'
    );
    expect(screen.getByRole('link', { name: 'Total: 5' })).toHaveAttribute(
      'href',
      '/hosts?search=status+%3D+error'
    );

    // owned counts link to their owner-scoped status searches
    expect(screen.getByRole('link', { name: 'Owned: 1' })).toHaveAttribute(
      'href',
      '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+ok'
    );
    expect(screen.getByRole('link', { name: 'Owned: 2' })).toHaveAttribute(
      'href',
      '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+warn'
    );
    expect(screen.getByRole('link', { name: 'Owned: 0' })).toHaveAttribute(
      'href',
      '/hosts?search=owner+%3D+current_user+AND+%28status+%3D+error'
    );
  });

  it('expands to reveal the status breakdown table', async () => {
    render(<Status name={name} />);

    // collapsed: the breakdown table is not rendered
    expect(screen.queryByLabelText('Host Statuses')).not.toBeInTheDocument();
    expect(screen.queryByText('OK')).not.toBeInTheDocument();

    await userEvent.click(screen.getByRole('button', { name: 'Details' }));

    // expanded: the OK/Warning/Error breakdown appears
    expect(screen.getByLabelText('Host Statuses')).toBeInTheDocument();
    expect(screen.getByText('OK')).toBeInTheDocument();
    expect(screen.getByText('Warning')).toBeInTheDocument();
    expect(screen.getByText('Error')).toBeInTheDocument();
  });
});
