import React from 'react';
import { screen, act } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';
import AuditsList from '../../AuditsList';
import { AuditsProps } from './AuditsList.fixtures';
import { rtlHelpers } from '../../../common/rtlTestHelpers';

const { renderWithI18n } = rtlHelpers;

const defaultProps = {
  data: { ...AuditsProps },
  fetchAndPush: jest.fn(),
};

const renderAuditsList = (props = {}) =>
  renderWithI18n(<AuditsList {...defaultProps} {...props} />);

const waitForList = () => screen.findByLabelText('Audits data list');

describe('AuditsList', () => {
  it('renders the audit data list', async () => {
    renderAuditsList();
    expect(await waitForList()).toBeInTheDocument();
  });

  it('renders user display name', async () => {
    renderAuditsList();
    await waitForList();
    expect(screen.getByText('Admin')).toBeInTheDocument();
  });

  it('renders the action display name', async () => {
    renderAuditsList();
    await waitForList();
    expect(screen.getByText('updated')).toBeInTheDocument();
  });

  it('renders the audited type name in uppercase', async () => {
    renderAuditsList();
    await waitForList();
    expect(screen.getByText('HOST')).toBeInTheDocument();
  });

  it('renders the audit title as a link', async () => {
    renderAuditsList();
    await waitForList();
    const links = screen.getAllByText('host-foo.example.com');
    expect(links.length).toBeGreaterThan(0);
    expect(links[0].closest('a')).toHaveAttribute(
      'href',
      '/audits?search=type+%3D+host+and+auditable_id+%3D+9'
    );
  });

  it('renders the remote address', async () => {
    renderAuditsList();
    await waitForList();
    expect(screen.getByText('(127.0.0.1)')).toBeInTheDocument();
  });

  it('shows expanded content after clicking toggle', async () => {
    renderAuditsList();
    await waitForList();

    expect(screen.queryByText('Request UUID')).not.toBeVisible();

    const toggle = screen.getByRole('button', { name: /details/i });
    await userEvent.click(toggle);

    expect(screen.getByText('Request UUID')).toBeVisible();
    expect(
      screen.getByText('c134239d-8ac3-494b-9962-35133fe153ba')
    ).toBeVisible();
  });

  it('renders affected organizations and locations when expanded', async () => {
    renderAuditsList();
    await waitForList();

    const toggle = screen.getByRole('button', { name: /details/i });
    await userEvent.click(toggle);

    expect(screen.getByText('Affected Organizations')).toBeVisible();
    expect(screen.getByText('test_org1')).toBeVisible();
    expect(screen.getByText('test_org2')).toBeVisible();
    expect(screen.getByText('test_org3')).toBeVisible();

    expect(screen.getByText('Affected Locations')).toBeVisible();
    expect(screen.getByText('test_loc1')).toBeVisible();
    expect(screen.getByText('test_loc2')).toBeVisible();
    expect(screen.getByText('test_loc3')).toBeVisible();
  });

  it('renders the allowed action link when expanded', async () => {
    renderAuditsList();
    await waitForList();

    const toggle = screen.getByRole('button', { name: /details/i });
    await userEvent.click(toggle);

    const actionLink = screen.getByRole('link', { name: 'Host details' });
    expect(actionLink).toBeVisible();
    expect(actionLink).toHaveAttribute(
      'href',
      '/hosts/host-foo.example.com'
    );
  });

  it('renders audited changes table when expanded', async () => {
    renderAuditsList();
    await waitForList();

    const toggle = screen.getByRole('button', { name: /details/i });
    await userEvent.click(toggle);

    expect(screen.getByText('Root pass')).toBeVisible();
    expect(screen.getByText('Comment')).toBeVisible();
    expect(
      screen.getByText('This is info about host for audit')
    ).toBeVisible();
  });

  it('calls fetchAndPush when request UUID button is clicked', async () => {
    const fetchAndPush = jest.fn();
    renderWithI18n(
      <AuditsList
        data={{ ...AuditsProps }}
        fetchAndPush={fetchAndPush}
      />
    );
    await waitForList();

    await act(async () => {
      const toggle = screen.getByRole('button', { name: /details/i });
      toggle.click();
    });

    await act(async () => {
      const uuidButton = screen.getByText(
        'c134239d-8ac3-494b-9962-35133fe153ba'
      );
      uuidButton.click();
    });

    expect(fetchAndPush).toHaveBeenCalledWith({
      searchQuery:
        'request_uuid = c134239d-8ac3-494b-9962-35133fe153ba',
    });
  });
});
