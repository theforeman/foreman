import React from 'react';
import { screen, within } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import ConfigParams from '../../components/fields/ConfigParams';
import { rtlHelpers } from '../../../../../common/rtlTestHelpers';
import { configParamsProps } from '../fixtures';

const { renderWithStore } = rtlHelpers;

const renderConfigParams = (props = {}) =>
  renderWithStore(<ConfigParams {...configParamsProps} {...props} />);

describe('RegistrationCommandsPage fields - ConfigParams', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders Setup REX and Setup Insights fields with default options', () => {
    renderConfigParams();

    const rexSelect = screen.getByLabelText('Setup REX');
    const insightsSelect = screen.getByLabelText('Setup Insights');

    expect(rexSelect).toBeInTheDocument();
    expect(insightsSelect).toBeInTheDocument();

    [rexSelect, insightsSelect].forEach(select => {
      expect(
        within(select).getByText('Inherit from host parameter (no)')
      ).toBeInTheDocument();
      expect(within(select).getByText('Yes (override)')).toBeInTheDocument();
      expect(within(select).getByText('No (override)')).toBeInTheDocument();
    });
  });

  it('shows inherited yes or no in default option labels from config params', () => {
    renderConfigParams({
      configParams: {
        host_registration_remote_execution: true,
        host_registration_insights: false,
      },
    });

    expect(
      within(screen.getByLabelText('Setup REX')).getByText(
        'Inherit from host parameter (yes)'
      )
    ).toBeInTheDocument();
    expect(
      within(screen.getByLabelText('Setup Insights')).getByText(
        'Inherit from host parameter (no)'
      )
    ).toBeInTheDocument();
  });

  it('shows the current selection from props', () => {
    renderConfigParams({
      setupRemoteExecution: 'true',
      setupInsights: 'false',
    });

    expect(screen.getByLabelText('Setup REX')).toHaveValue('true');
    expect(screen.getByLabelText('Setup Insights')).toHaveValue('false');
  });

  it('calls handleRemoteExecution when inherit option is selected', async () => {
    const handleRemoteExecution = jest.fn();

    renderConfigParams({
      setupRemoteExecution: 'true',
      handleRemoteExecution,
    });

    const rexSelect = screen.getByLabelText('Setup REX');
    await userEvent.selectOptions(
      rexSelect,
      within(rexSelect).getByRole('option', {
        name: 'Inherit from host parameter (no)',
      })
    );

    expect(handleRemoteExecution).toHaveBeenCalledWith('');
  });

  it('calls handleRemoteExecution when Setup REX selection changes', async () => {
    const handleRemoteExecution = jest.fn();

    renderConfigParams({ handleRemoteExecution });

    const rexSelect = screen.getByLabelText('Setup REX');
    await userEvent.selectOptions(
      rexSelect,
      within(rexSelect).getByRole('option', { name: 'Yes (override)' })
    );

    expect(handleRemoteExecution).toHaveBeenCalledWith('true');
  });

  it('calls handleInsights when Setup Insights selection changes', async () => {
    const handleInsights = jest.fn();

    renderConfigParams({ handleInsights });

    const insightsSelect = screen.getByLabelText('Setup Insights');
    await userEvent.selectOptions(
      insightsSelect,
      within(insightsSelect).getByRole('option', { name: 'No (override)' })
    );

    expect(handleInsights).toHaveBeenCalledWith('false');
  });

  it('disables selects when loading', () => {
    renderConfigParams({ isLoading: true });

    expect(screen.getByLabelText('Setup REX')).toBeDisabled();
    expect(screen.getByLabelText('Setup Insights')).toBeDisabled();
  });
});
