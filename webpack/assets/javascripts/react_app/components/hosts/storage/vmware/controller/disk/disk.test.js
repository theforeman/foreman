import React from 'react';
import { render, screen, fireEvent, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';
import Disk from './';
import {
  props,
  datastoresStubData,
  storagePodsStubData,
  defaultDiskModeTypes,
} from './disk.fixtures';
import { STATUS } from '../../../../../../constants';

describe('Disk', () => {
  const defaultProps = {
    ...props,
    config: {
      diskModeTypes: defaultDiskModeTypes,
      vmExists: false,
    },
    datastores: datastoresStubData('cfme'),
    storagePods: storagePodsStubData,
    datastoresStatus: undefined,
    datastoresError: undefined,
    storagePodsStatus: undefined,
    storagePodsError: undefined,
    volumeNumber: 1,
  };

  const expandVolume = async () => {
    const toggleButton = screen.getByRole('button', {
      name: /Hard disk|Test Disk/,
    });
    await act(async () => {
      await userEvent.click(toggleButton);
    });
  };

  describe('Rendering', () => {
    it('renders volume header with title and size', () => {
      render(<Disk {...defaultProps} name="Test Disk" sizeGb={10} />);
      expect(screen.getByText('Test Disk')).toBeInTheDocument();
      expect(screen.getByText('10 GB')).toBeInTheDocument();
    });

    it('renders form fields when expanded', async () => {
      render(<Disk {...defaultProps} name="Test Disk" />);
      await expandVolume();

      expect(screen.getByText('Storage Pod')).toBeInTheDocument();
      expect(screen.getByText('Data store')).toBeInTheDocument();
      expect(screen.getByText('Disk mode')).toBeInTheDocument();
      expect(screen.getByText('Size (GB)')).toBeInTheDocument();
      expect(screen.getByText('Thin provision')).toBeInTheDocument();
      expect(screen.getByText('Eager zero')).toBeInTheDocument();
    });

    it('hides form fields when collapsed', () => {
      render(<Disk {...defaultProps} name="Test Disk" />);

      expect(screen.getByText('Storage Pod')).not.toBeVisible();
      expect(screen.getByText('Data store')).not.toBeVisible();
      expect(screen.getByText('Disk mode')).not.toBeVisible();
    });

    it('renders size input with correct value when expanded', async () => {
      const { container } = render(<Disk {...defaultProps} sizeGb={10} />);
      await expandVolume();

      const sizeInput = container.querySelector('.text-vmware-size input');
      expect(sizeInput).toBeInTheDocument();
      expect(sizeInput).toHaveValue(10);
    });

    it('renders thin provision checkbox with correct checked state', async () => {
      const { container } = render(<Disk {...defaultProps} thin={true} />);
      await expandVolume();

      const thinCheckbox = container.querySelector('#checkbox-thin-provision');
      expect(thinCheckbox).toBeChecked();
      const eagerZeroCheckbox = container.querySelector('#checkbox-eager-zero');
      expect(eagerZeroCheckbox).not.toBeChecked();
    });

    it('renders eager zero checkbox with correct checked state', async () => {
      const { container } = render(
        <Disk {...defaultProps} eagerZero={true} thin={false} />
      );
      await expandVolume();

      const thinCheckbox = container.querySelector('#checkbox-thin-provision');
      expect(thinCheckbox).not.toBeChecked();
      const eagerZeroCheckbox = container.querySelector('#checkbox-eager-zero');
      expect(eagerZeroCheckbox).toBeChecked();
    });

    it('falls back to numbered default label when name is empty', () => {
      render(<Disk {...defaultProps} volumeNumber={3} name="" />);
      expect(screen.getByText(/Hard disk 3/)).toBeInTheDocument();
    });
  });

  describe('Remove volume Button', () => {
    it('renders remove button when vmExists is false', () => {
      render(<Disk {...defaultProps} />);
      const removeButton = screen.getByRole('button', {
        name: 'Remove volume',
      });
      expect(removeButton).toBeInTheDocument();
    });

    it('does not render remove button when vmExists is true', () => {
      render(
        <Disk
          {...defaultProps}
          config={{ ...defaultProps.config, vmExists: true }}
        />
      );
      expect(
        screen.queryByRole('button', { name: 'Remove volume' })
      ).not.toBeInTheDocument();
    });

    it('calls removeDisk when remove button is clicked', async () => {
      const removeDisk = jest.fn();
      render(<Disk {...defaultProps} removeDisk={removeDisk} />);
      const removeButton = screen.getByRole('button', {
        name: 'Remove volume',
      });

      await userEvent.click(removeButton);
      expect(removeDisk).toHaveBeenCalledTimes(1);
    });
  });

  describe('Storage pod and Data store mutual exclusivity', () => {
    it('hides datastore field when storagePod is selected', async () => {
      render(<Disk {...defaultProps} storagePod="StorageCluster" />);
      await expandVolume();

      expect(screen.queryByText('Data store')).not.toBeInTheDocument();
      expect(screen.getByText('Storage Pod')).toBeInTheDocument();
    });

    it('hides storagePod field when datastore is selected', async () => {
      const datastoreKey = Object.keys(datastoresStubData('cfme'))[0];
      render(<Disk {...defaultProps} datastore={datastoreKey} />);
      await expandVolume();

      expect(screen.queryByText('Storage Pod')).not.toBeInTheDocument();
      expect(screen.getByText('Data store')).toBeInTheDocument();
    });

    it('shows both fields when neither is selected', async () => {
      render(<Disk {...defaultProps} storagePod="" datastore="" />);
      await expandVolume();

      expect(screen.getByText('Storage Pod')).toBeInTheDocument();
      expect(screen.getByText('Data store')).toBeInTheDocument();
    });
  });

  describe('Disk mode Selection', () => {
    it('displays the correct selected disk mode', async () => {
      render(<Disk {...defaultProps} mode="independent_persistent" />);
      await expandVolume();
      expect(screen.getByText('Independent - Persistent')).toBeInTheDocument();
    });

    it('is disabled when vmExists is true', async () => {
      render(
        <Disk
          {...defaultProps}
          config={{ ...defaultProps.config, vmExists: true }}
          mode="persistent"
        />
      );
      const toggleButton = screen.getByRole('button', { name: /Hard disk 1/ });
      await act(async () => {
        await userEvent.click(toggleButton);
      });

      expect(screen.getByRole('button', { name: 'Persistent' })).toBeDisabled();
    });
  });

  describe('Size Input', () => {
    it('calls updateDisk when size changes via input', async () => {
      const updateDisk = jest.fn();
      render(<Disk {...defaultProps} updateDisk={updateDisk} sizeGb={10} />);
      await expandVolume();

      const sizeInput = document.querySelector('.text-vmware-size input');
      expect(sizeInput).toBeInTheDocument();
      fireEvent.change(sizeInput, { target: { value: '20' } });
      expect(updateDisk).toHaveBeenCalledWith('sizeGb', 20);
    });

    it('calls updateDisk when plus button is clicked', async () => {
      const updateDisk = jest.fn();
      render(<Disk {...defaultProps} updateDisk={updateDisk} sizeGb={10} />);
      await expandVolume();

      const numberInput = document.querySelector('.text-vmware-size');
      expect(numberInput).toBeInTheDocument();
      const plusButton =
        numberInput.querySelector('button[aria-label="Plus"]') ||
        numberInput.querySelector('button:last-child');
      expect(plusButton).toBeInTheDocument();
      fireEvent.click(plusButton);
      expect(updateDisk).toHaveBeenCalledWith('sizeGb', 11);
    });

    it('calls updateDisk when minus button is clicked', async () => {
      const updateDisk = jest.fn();
      render(<Disk {...defaultProps} updateDisk={updateDisk} sizeGb={10} />);
      await expandVolume();

      const numberInput = document.querySelector('.text-vmware-size');
      expect(numberInput).toBeInTheDocument();
      const minusButton =
        numberInput.querySelector('button[aria-label="Minus"]') ||
        numberInput.querySelector('button:first-child');
      expect(minusButton).toBeInTheDocument();
      fireEvent.click(minusButton);
      expect(updateDisk).toHaveBeenCalledWith('sizeGb', 9);
    });

    it('clamps negative values to 1', async () => {
      const updateDisk = jest.fn();
      render(<Disk {...defaultProps} updateDisk={updateDisk} sizeGb={10} />);
      await expandVolume();

      const sizeInput = document.querySelector('.text-vmware-size input');
      fireEvent.change(sizeInput, { target: { value: '-5' } });
      expect(updateDisk).toHaveBeenCalledWith('sizeGb', 1);
    });

    it('handles zero sizeGb value', async () => {
      const { container } = render(<Disk {...defaultProps} sizeGb={0} />);
      await expandVolume();

      const numberInput = container.querySelector('.text-vmware-size');
      expect(numberInput).toBeInTheDocument();
      const sizeInput = numberInput?.querySelector('input');
      expect(sizeInput).toBeInTheDocument();
      expect(sizeInput).toHaveValue(0);
      const minusButton =
        numberInput?.querySelector('button[aria-label="Minus"]') ||
        numberInput?.querySelector('button:first-child');
      expect(minusButton).toBeDisabled();
    });
  });

  describe('Thin Provision Checkbox', () => {
    it('calls updateDisk when thin provision is toggled', async () => {
      const updateDisk = jest.fn();
      const { container } = render(
        <Disk {...defaultProps} updateDisk={updateDisk} thin={false} />
      );
      await expandVolume();

      const thinCheckbox = container.querySelector('#checkbox-thin-provision');
      await userEvent.click(thinCheckbox);

      expect(updateDisk).toHaveBeenCalledWith('thin', true);
    });

    it('disables eager zero when thin provision is checked', async () => {
      const { container } = render(<Disk {...defaultProps} thin={true} />);
      await expandVolume();

      const thinCheckbox = container.querySelector('#checkbox-thin-provision');
      const eagerZeroCheckbox = container.querySelector('#checkbox-eager-zero');
      expect(thinCheckbox).toBeChecked();
      expect(eagerZeroCheckbox).toBeDisabled();
    });

    it('sets eagerZero to false when thin provision is enabled', async () => {
      const updateDisk = jest.fn();
      const { container } = render(
        <Disk
          {...defaultProps}
          updateDisk={updateDisk}
          thin={false}
          eagerZero={false}
        />
      );
      await expandVolume();

      const thinCheckbox = container.querySelector('#checkbox-thin-provision');
      expect(thinCheckbox).not.toBeDisabled();
      await userEvent.click(thinCheckbox);

      expect(updateDisk).toHaveBeenCalledWith('thin', true);
      expect(updateDisk).toHaveBeenCalledWith('eagerZero', false);
    });

    it('is disabled when vmExists is true', async () => {
      const { container } = render(
        <Disk
          {...defaultProps}
          config={{ ...defaultProps.config, vmExists: true }}
        />
      );
      const toggleButton = screen.getByRole('button', { name: /Hard disk 1/ });
      await act(async () => {
        await userEvent.click(toggleButton);
      });

      const thinCheckbox = container.querySelector('#checkbox-thin-provision');
      expect(thinCheckbox).toBeDisabled();
    });

    it('is disabled when eagerZero is true', async () => {
      const { container } = render(<Disk {...defaultProps} eagerZero={true} />);
      await expandVolume();

      const thinCheckbox = container.querySelector('#checkbox-thin-provision');
      expect(thinCheckbox).toBeDisabled();
    });
  });

  describe('Eager Zero Checkbox', () => {
    it('calls updateDisk when eager zero is toggled', async () => {
      const updateDisk = jest.fn();
      const { container } = render(
        <Disk
          {...defaultProps}
          updateDisk={updateDisk}
          eagerZero={false}
          thin={false}
        />
      );
      await expandVolume();

      const eagerZeroCheckbox = container.querySelector('#checkbox-eager-zero');
      expect(eagerZeroCheckbox).not.toBeDisabled();
      await userEvent.click(eagerZeroCheckbox);

      expect(updateDisk).toHaveBeenCalledWith('eagerZero', true);
    });

    it('disables thin provision when eager zero is checked', async () => {
      const { container } = render(
        <Disk {...defaultProps} thin={false} eagerZero={true} />
      );
      await expandVolume();

      const thinCheckbox = container.querySelector('#checkbox-thin-provision');
      expect(thinCheckbox).toBeDisabled();
    });

    it('sets thin to false when eager zero is enabled', async () => {
      const updateDisk = jest.fn();
      const { container } = render(
        <Disk
          {...defaultProps}
          updateDisk={updateDisk}
          thin={false}
          eagerZero={false}
        />
      );
      await expandVolume();

      const eagerZeroCheckbox = container.querySelector('#checkbox-eager-zero');
      expect(eagerZeroCheckbox).not.toBeDisabled();
      await userEvent.click(eagerZeroCheckbox);

      expect(updateDisk).toHaveBeenCalledWith('eagerZero', true);
      expect(updateDisk).toHaveBeenCalledWith('thin', false);
    });

    it('is disabled when vmExists is true', async () => {
      const { container } = render(
        <Disk
          {...defaultProps}
          config={{ ...defaultProps.config, vmExists: true }}
        />
      );
      const toggleButton = screen.getByRole('button', { name: /Hard disk 1/ });
      await act(async () => {
        await userEvent.click(toggleButton);
      });

      const eagerZeroCheckbox = container.querySelector('#checkbox-eager-zero');
      expect(eagerZeroCheckbox).toBeDisabled();
    });
  });

  describe('FormStatus Integration', () => {
    it('renders FormStatus for storagePods when status is PENDING', async () => {
      render(
        <Disk
          {...defaultProps}
          storagePodsStatus={STATUS.PENDING}
          storagePod=""
          datastore=""
        />
      );
      await expandVolume();

      const spinner = document.querySelector('.pf-v5-c-spinner');
      expect(spinner).toBeInTheDocument();
    });

    it('renders FormStatus for datastores when status is ERROR', async () => {
      const { container } = render(
        <Disk
          {...defaultProps}
          datastoresStatus={STATUS.ERROR}
          datastoresError="Error loading datastores"
          storagePod=""
          datastore=""
        />
      );
      await expandVolume();

      const errorButton = container.querySelector(
        '[data-ouia-component-id="error-popover-button-datastores"]'
      );
      expect(errorButton).toBeInTheDocument();
    });
  });

  describe('Disabled States', () => {
    it('disables inputs when vmExists is true', async () => {
      const { container } = render(
        <Disk
          {...defaultProps}
          config={{ ...defaultProps.config, vmExists: true }}
          storagePod=""
          datastore=""
        />
      );
      const toggleButton = screen.getByRole('button', { name: /Hard disk 1/ });
      await act(async () => {
        await userEvent.click(toggleButton);
      });

      const typeaheadInputs = container.querySelectorAll(
        'input[aria-label="Type to filter"]'
      );
      expect(typeaheadInputs.length).toBeGreaterThan(0);
      const disabledToggles = container.querySelectorAll('.pf-m-disabled');
      expect(disabledToggles.length).toBeGreaterThan(0);
    });
  });
});
