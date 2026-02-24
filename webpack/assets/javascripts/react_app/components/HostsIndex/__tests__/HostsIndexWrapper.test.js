import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom';
import HostsIndexWrapper from '../HostsIndexWrapper';

const mockUseForemanPermissions = jest.fn();

jest.mock('../../../Root/Context/ForemanContext', () => ({
  useForemanPermissions: () => mockUseForemanPermissions(),
}));

jest.mock('../../PermissionDenied', () => ({
  __esModule: true,
  default: ({ missingPermissions }) => (
    <div data-testid="permission-denied">
      Permission Denied: {missingPermissions.join(', ')}
    </div>
  ),
}));

jest.mock('../index', () => ({
  __esModule: true,
  default: props => (
    <div data-testid="hosts-index" data-props={JSON.stringify(props)}>
      HostsIndex
    </div>
  ),
}));

describe('HostsIndexWrapper', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('with view_hosts permission', () => {
    beforeEach(() => {
      mockUseForemanPermissions.mockReturnValue(new Set(['view_hosts']));
    });

    test('renders HostsIndex component', () => {
      render(<HostsIndexWrapper />);

      expect(screen.getByTestId('hosts-index')).toBeInTheDocument();
      expect(screen.queryByTestId('permission-denied')).not.toBeInTheDocument();
    });

    test('passes props to HostsIndex component', () => {
      const testProps = {
        foo: 'bar',
        baz: 123,
      };

      render(<HostsIndexWrapper {...testProps} />);

      const hostsIndex = screen.getByTestId('hosts-index');
      const receivedProps = JSON.parse(hostsIndex.getAttribute('data-props'));

      expect(receivedProps).toEqual(testProps);
    });
  });

  describe('without view_hosts permission', () => {
    beforeEach(() => {
      mockUseForemanPermissions.mockReturnValue(new Set(['some_other_permission']));
    });

    test('renders PermissionDenied component', () => {
      render(<HostsIndexWrapper />);

      expect(screen.getByTestId('permission-denied')).toBeInTheDocument();
      expect(screen.getByText(/Permission Denied: view_hosts/)).toBeInTheDocument();
    });

    test('does not render HostsIndex component', () => {
      render(<HostsIndexWrapper />);

      expect(screen.queryByTestId('hosts-index')).not.toBeInTheDocument();
    });
  });

  describe('with no permissions', () => {
    beforeEach(() => {
      mockUseForemanPermissions.mockReturnValue(new Set());
    });

    test('renders PermissionDenied component', () => {
      render(<HostsIndexWrapper />);

      expect(screen.getByTestId('permission-denied')).toBeInTheDocument();
      expect(screen.queryByTestId('hosts-index')).not.toBeInTheDocument();
    });
  });
});
