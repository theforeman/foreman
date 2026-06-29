import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import '@testing-library/jest-dom';

import HostGroup from '../../components/fields/HostGroup';
import { hostGroupProps } from '../fixtures';

const renderHostGroup = (props = {}) => {
  const defaultProps = {
    ...hostGroupProps,
    ...props,
  };

  return render(<HostGroup {...defaultProps} />);
};

describe('RegistrationCommandsPage fields - HostGroup', () => {
  it('renders the host group form field with options', () => {
    renderHostGroup();

    expect(screen.getByLabelText('Host group')).toBeInTheDocument();
    expect(screen.getByText('test_hg')).toBeInTheDocument();
  });

  it('calls handleHostGroup when selection changes', () => {
    const handleHostGroup = jest.fn();
    const hostGroups = [
      { id: 0, title: 'test_hg' },
      { id: 1, title: 'other_hg' },
    ];

    renderHostGroup({ handleHostGroup, hostGroups });

    fireEvent.change(screen.getByLabelText('Host group'), {
      target: { value: '1' },
    });

    expect(handleHostGroup).toHaveBeenCalledWith('1');
  });

  it('is disabled when loading', () => {
    renderHostGroup({ isLoading: true });

    expect(screen.getByLabelText('Host group')).toBeDisabled();
  });

  it('is disabled when no host groups are available', () => {
    renderHostGroup({ hostGroups: [] });

    expect(screen.getByLabelText('Host group')).toBeDisabled();
  });

  it('shows empty state message when no host groups are available', () => {
    renderHostGroup({ hostGroups: [] });

    expect(screen.getByText('Nothing to select.')).toBeInTheDocument();
  });
});
