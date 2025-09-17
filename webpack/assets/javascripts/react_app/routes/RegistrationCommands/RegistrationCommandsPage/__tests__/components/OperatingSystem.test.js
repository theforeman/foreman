import React from 'react';
import { screen, fireEvent, waitFor, act } from '@testing-library/react';
import '@testing-library/jest-dom';

import userEvent from '@testing-library/user-event';

import OperatingSystem from '../../components/fields/OperatingSystem';
import { rtlHelpers } from '../../../../../common/rtlTestHelpers';
import { osProps } from '../fixtures';

const { renderWithStore } = rtlHelpers;

const renderWithProvider = (props = {}) => {
  const defaultProps = {
    ...osProps,
    ...props,
  };

  return renderWithStore(<OperatingSystem {...defaultProps} />);
};

describe('RegistrationCommandsPage fields - OperatingSystem', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('should render the operating system form group', async () => {
    jest.useFakeTimers();
    renderWithProvider();

    expect(screen.getByText('Operating system')).toBeInTheDocument();
    const tooltip = screen.getByRole('button');
    await act(async () => userEvent.click(tooltip));
    await act(async () => jest.advanceTimersByTime(1000));
    expect(
      screen.getByText(
        'Required for registration without subscription manager. Can be specified by host group.'
      )
    ).toBeInTheDocument();
  });

  it('should render the form select with correct attributes', () => {
    renderWithProvider();

    const select = screen.getByRole('combobox');
    expect(select).toBeInTheDocument();
    expect(select).toHaveAttribute('id', 'reg_os');
    expect(select).toHaveAttribute('data-ouia-component-id', 'os-select');
    expect(select).toBeVisible();
  });

  it('should render operating system options', () => {
    const operatingSystems = [
      { id: 1, title: 'Red Hat Enterprise Linux 8' },
      { id: 2, title: 'CentOS 8' },
    ];

    renderWithProvider({ operatingSystems });

    expect(screen.getByText('Red Hat Enterprise Linux 8')).toBeInTheDocument();
    expect(screen.getByText('CentOS 8')).toBeInTheDocument();
  });

  it('should call handleOperatingSystem when selection changes', () => {
    const handleOperatingSystem = jest.fn();
    const operatingSystems = [{ id: 1, title: 'Red Hat Enterprise Linux 8' }];

    renderWithProvider({
      operatingSystems,
      handleOperatingSystem,
    });

    const select = screen.getByRole('combobox');
    fireEvent.change(select, { target: { value: '1' } });

    expect(handleOperatingSystem).toHaveBeenCalledWith('1');
  });

  it('should be disabled when loading', () => {
    renderWithProvider({ isLoading: true });

    const select = screen.getByRole('combobox');
    expect(select).toBeDisabled();
  });

  it('should be disabled when no operating systems available', () => {
    renderWithProvider({ operatingSystems: [] });

    const select = screen.getByRole('combobox');
    expect(select).toBeDisabled();
  });

  it('should call handleInvalidField when operatingSystemId is empty', async () => {
    const handleInvalidField = jest.fn();

    renderWithProvider({
      operatingSystemId: '',
      handleInvalidField,
    });

    await waitFor(() => {
      expect(handleInvalidField).toHaveBeenCalledWith('Operating system', true);
    });
  });

  it('should call handleInvalidField when operatingSystemTemplate has name', async () => {
    const handleInvalidField = jest.fn();
    const operatingSystemTemplate = { name: 'Test Template' };

    renderWithProvider({
      operatingSystemId: '1',
      operatingSystemTemplate,
      handleInvalidField,
    });

    await waitFor(() => {
      expect(handleInvalidField).toHaveBeenCalledWith('Operating system', true);
    });
  });

  it('should call handleInvalidField when operatingSystemTemplate has no name', async () => {
    const handleInvalidField = jest.fn();
    const operatingSystemTemplate = { name: null };

    renderWithProvider({
      operatingSystemId: '1',
      operatingSystemTemplate,
      handleInvalidField,
    });

    await waitFor(() => {
      expect(handleInvalidField).toHaveBeenCalledWith(
        'Operating system',
        false
      );
    });
  });
});
