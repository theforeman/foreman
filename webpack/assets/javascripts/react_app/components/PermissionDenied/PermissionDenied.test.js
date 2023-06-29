import React from 'react';
import { screen, render } from '@testing-library/react';
import PermissionDenied from './PermissionDenied';

describe('PermissionDenied', () => {
  it('renders the header and description', () => {
    const missingPermissions = ['permission1', 'permission2'];
    render(<PermissionDenied missingPermissions={missingPermissions} />);

    expect(screen.getAllByText('Permission Denied')).toHaveLength(1);
    expect(screen.getAllByText(/You are not authorized to perform this action./)).toHaveLength(1);
    expect(screen.getAllByText(/Please request one of the required permissions listed below from a Foreman administrator:/)).toHaveLength(1);
  });

  it('renders the missing permissions', () => {
    const missingPermissions = ['permission1', 'permission2'];
    render(<PermissionDenied missingPermissions={missingPermissions} />);

    expect(screen.getAllByText('permission1')).toHaveLength(1);
    expect(screen.getAllByText('permission2')).toHaveLength(1);
  });

  it('renders the default missing permission', () => {
    render(<PermissionDenied />);

    expect(screen.getAllByText('unknown')).toHaveLength(1);
  });
});