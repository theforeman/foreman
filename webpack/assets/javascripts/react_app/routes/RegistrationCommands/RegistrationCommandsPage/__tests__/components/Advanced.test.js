import React from 'react';
import { screen, waitFor, within } from '@testing-library/react';
import '@testing-library/jest-dom';

import userEvent from '@testing-library/user-event';

import Advanced from '../../components/Advanced';
import { rtlHelpers } from '../../../../../common/rtlTestHelpers';
import { advancedComponentProps } from '../fixtures';

const { renderWithStore } = rtlHelpers;

const renderAdvanced = (props = {}) => {
  const defaultProps = {
    ...advancedComponentProps,
    ...props,
  };

  return renderWithStore(<Advanced {...defaultProps} />);
};

describe('RegistrationCommandsPage - Advanced', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders advanced registration form fields', () => {
    renderAdvanced();

    expect(
      screen.getByRole('combobox', { name: /Setup REX/i })
    ).toBeInTheDocument();
    expect(
      screen.getByRole('combobox', { name: /Setup Insights/i })
    ).toBeInTheDocument();
    expect(screen.getByLabelText('Install packages')).toBeInTheDocument();
    expect(
      screen.getByRole('checkbox', { name: /Update packages/i })
    ).toBeInTheDocument();
    expect(screen.getByText('Repositories')).toBeInTheDocument();
    expect(screen.getByLabelText('Token life time')).toBeInTheDocument();
    expect(
      screen.getByRole('button', {
        name: 'Add repositories for registration (0 set)',
      })
    ).toBeInTheDocument();
  });

  it('enables form fields when not loading', () => {
    renderAdvanced({ isLoading: false });

    expect(
      screen.getByRole('combobox', { name: /Setup REX/i })
    ).toBeEnabled();
    expect(
      screen.getByRole('combobox', { name: /Setup Insights/i })
    ).toBeEnabled();
    expect(screen.getByLabelText('Install packages')).toBeEnabled();
    expect(
      screen.getByRole('checkbox', { name: /Update packages/i })
    ).toBeEnabled();
    expect(screen.getByLabelText('Token life time')).toBeEnabled();
    expect(screen.getByLabelText('unlimited')).toBeEnabled();
    expect(
      screen.getByRole('button', {
        name: 'Add repositories for registration (0 set)',
      })
    ).toBeEnabled();
  });

  it('disables form fields when loading', () => {
    renderAdvanced({ isLoading: true });

    expect(
      screen.getByRole('combobox', { name: /Setup REX/i })
    ).toBeDisabled();
    expect(
      screen.getByRole('combobox', { name: /Setup Insights/i })
    ).toBeDisabled();
    expect(screen.getByLabelText('Install packages')).toBeDisabled();
    expect(
      screen.getByRole('checkbox', { name: /Update packages/i })
    ).toBeDisabled();
    expect(screen.getByLabelText('Token life time')).toBeDisabled();
    expect(screen.getByLabelText('unlimited')).toBeDisabled();
  });

  describe('ConfigParams', () => {
    it('shows inherited host parameter defaults', () => {
      renderAdvanced({
        configParams: {
          host_registration_remote_execution: true,
          host_registration_insights: false,
        },
      });

      expect(
        screen.getByRole('option', {
          name: /Inherit from host parameter \(yes\)/i,
        })
      ).toBeInTheDocument();
      expect(
        screen.getByRole('option', {
          name: /Inherit from host parameter \(no\)/i,
        })
      ).toBeInTheDocument();
    });

    it('calls handleRemoteExecution when Setup REX selection changes', async () => {
      const handleRemoteExecution = jest.fn();

      renderAdvanced({ handleRemoteExecution });

      const rexSelect = screen.getByRole('combobox', { name: /Setup REX/i });

      await userEvent.selectOptions(
        rexSelect,
        within(rexSelect).getByRole('option', { name: 'Yes (override)' })
      );

      expect(handleRemoteExecution).toHaveBeenCalledWith('true');
    });

    it('calls handleInsights when Setup Insights selection changes', async () => {
      const handleInsights = jest.fn();

      renderAdvanced({ handleInsights });

      const insightsSelect = screen.getByRole('combobox', {
        name: /Setup Insights/i,
      });

      await userEvent.selectOptions(
        insightsSelect,
        within(insightsSelect).getByRole('option', { name: 'No (override)' })
      );

      expect(handleInsights).toHaveBeenCalledWith('false');
    });
  });

  describe('Packages', () => {
    it('renders package value and default hint', () => {
      renderAdvanced({
        configParams: { host_packages: 'vim git' },
        packages: 'curl wget',
      });

      const installPackagesInput = screen.getByLabelText('Install packages');

      expect(installPackagesInput).toBeInTheDocument();
      expect(installPackagesInput).toHaveValue('curl wget');
      expect(screen.getByText('Default value: "vim git"')).toBeInTheDocument();
    });

    it('calls handlePackages when install packages input changes', async () => {
      const handlePackages = jest.fn();

      renderAdvanced({ handlePackages });

      const installPackagesInput = screen.getByLabelText('Install packages');

      await userEvent.type(installPackagesInput, 'a');

      expect(handlePackages).toHaveBeenLastCalledWith('a');
    });
  });

  describe('UpdatePackages', () => {
    it('renders checked update packages checkbox', () => {
      renderAdvanced({ updatePackages: true });

      expect(
        screen.getByRole('checkbox', { name: /Update packages/i })
      ).toBeChecked();
    });

    it('calls handleUpdatePackages when checkbox is clicked', async () => {
      const handleUpdatePackages = jest.fn();

      renderAdvanced({ handleUpdatePackages });

      await userEvent.click(
        screen.getByRole('checkbox', { name: /Update packages/i })
      );

      expect(handleUpdatePackages).toHaveBeenCalledWith(true);
    });
  });

  describe('Repository', () => {
    it('renders repositories section with configured count', () => {
      renderAdvanced({
        repoData: [{ reference: 0, repository: 'BaseOS', gpgKeyUrl: '' }],
      });

      expect(screen.getByText('Repositories')).toBeInTheDocument();
      expect(
        screen.getByRole('button', {
          name: 'Add repositories for registration (1 set)',
        })
      ).toBeInTheDocument();
    });

    it('calls handleRepoData when repoData is empty on mount', async () => {
      const handleRepoData = jest.fn();

      renderAdvanced({ repoData: [], handleRepoData });

      await waitFor(() => {
        expect(handleRepoData).toHaveBeenCalledWith([
          { reference: 0, repository: '', gpgKeyUrl: '' },
        ]);
      });
    });
  });

  describe('TokenLifeTime', () => {
    it('renders token life time field with value', () => {
      renderAdvanced({ jwtExpiration: 8 });

      expect(screen.getByLabelText('Token life time')).toBeInTheDocument();
      expect(screen.getByLabelText('Token life time')).toHaveValue(8);
    });

    it('calls handleJwtExpiration when token life time changes', async () => {
      const handleJwtExpiration = jest.fn();

      renderAdvanced({ jwtExpiration: 4, handleJwtExpiration });

      await userEvent.clear(screen.getByLabelText('Token life time'));
      await userEvent.type(screen.getByLabelText('Token life time'), '12');

      expect(handleJwtExpiration).toHaveBeenLastCalledWith('12');
    });

    it('calls handleInvalidField when token life time changes', async () => {
      const handleInvalidField = jest.fn();

      renderAdvanced({ jwtExpiration: 4, handleInvalidField });

      await userEvent.clear(screen.getByLabelText('Token life time'));
      await userEvent.type(screen.getByLabelText('Token life time'), '0');

      expect(handleInvalidField).toHaveBeenLastCalledWith(
        'Token life time',
        false
      );
    });

    it('calls handleJwtExpiration and handleInvalidField when unlimited is toggled', async () => {
      const handleJwtExpiration = jest.fn();
      const handleInvalidField = jest.fn();

      renderAdvanced({ jwtExpiration: 4, handleJwtExpiration, handleInvalidField });

      await userEvent.click(screen.getByLabelText('unlimited'));

      expect(handleJwtExpiration).toHaveBeenCalledWith('unlimited');
      expect(handleInvalidField).toHaveBeenCalledWith('Token life time', true);
    });
  });
});
