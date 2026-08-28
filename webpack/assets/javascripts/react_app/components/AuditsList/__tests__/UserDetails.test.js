import React from 'react';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import '@testing-library/jest-dom';

import UserDetails from '../UserDetails';
import { AuditRecord } from './AuditsList.fixtures';

const defaultProps = {
  userInfo: AuditRecord.user_info,
  remoteAddress: AuditRecord.remote_address,
  isAuditLogin: false,
};

// Plain render: renderWithI18n prevents PF Tooltip from rendering its children.
const renderUserDetails = (props = {}) =>
  render(<UserDetails {...defaultProps} {...props} />);

const userLinkName = AuditRecord.user_info.display_name.trim();

describe('UserDetails', () => {
  it('renders user display name as a filter link', () => {
    renderUserDetails();

    const userLink = screen.getByRole('link', { name: userLinkName });

    expect(userLink).toBeInTheDocument();
    expect(userLink).toHaveAttribute(
      'href',
      AuditRecord.user_info.search_path
    );
  });

  it('renders remote address when provided', () => {
    renderUserDetails();

    expect(screen.getByText(`(${AuditRecord.remote_address})`)).toBeInTheDocument();
  });

  it('does not render remote address when it is not provided', () => {
    renderUserDetails({ remoteAddress: undefined });

    expect(screen.queryByText(/\(\d+\.\d+\.\d+\.\d+\)/)).not.toBeInTheDocument();
  });

  it('renders logged-in link for audit login events', () => {
    renderUserDetails({ isAuditLogin: true });

    const loggedInLink = screen.getByRole('link', { name: 'Logged-in' });

    expect(loggedInLink).toBeInTheDocument();
    expect(loggedInLink).toHaveAttribute(
      'href',
      AuditRecord.user_info.audit_path
    );
  });

  it('does not render remote address for audit login events', () => {
    renderUserDetails({ isAuditLogin: true });

    expect(screen.queryByText(`(${AuditRecord.remote_address})`)).not.toBeInTheDocument();
  });

  it('shows filter tooltip on user link hover', async () => {
    renderUserDetails();

    expect(screen.queryByRole('tooltip')).not.toBeInTheDocument();

    userEvent.hover(screen.getByRole('link', { name: userLinkName }));

    expect(await screen.findByRole('tooltip')).toHaveTextContent(
      'Filter audits for this user only'
    );
  });
});
