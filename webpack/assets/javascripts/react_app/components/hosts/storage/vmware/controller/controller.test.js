import React from 'react';
import { render, screen, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';
import Controller from './';
import { props } from './controller.fixtures';

describe('Controller', () => {
  jest.useFakeTimers();
  const defaultProps = {
    ...props,
    config: {
      ...props.config,
      vmExists: false,
    },
  };

  describe('Rendering', () => {
    it('renders controller form with all elements', () => {
      render(<Controller {...defaultProps} />);

      expect(screen.getByText('Controller')).toBeInTheDocument();
      expect(screen.getByText('Add another volume')).toBeInTheDocument();
      expect(
        screen.getByRole('button', { name: 'Remove controller' })
      ).toBeInTheDocument();

      expect(screen.getByText('LSI Logic Parallel')).toBeInTheDocument();

      expect(screen.getByText('Hard disk 1')).toBeInTheDocument();
    });

    it('renders Add volume when controllerVolumes is empty', () => {
      render(<Controller {...defaultProps} controllerVolumes={[]} />);

      expect(screen.queryByText(/Volume/)).not.toBeInTheDocument();
      expect(screen.getByText('Add volume')).toBeInTheDocument();
    });
  });

  describe('Controller Type Selection', () => {
    it('displays the correct selected controller type', () => {
      render(
        <Controller
          {...defaultProps}
          controller={{ type: 'VirtualBusLogicController', key: 1000 }}
        />
      );
      expect(screen.getByText('Bus Logic Parallel')).toBeInTheDocument();
    });

    it('is disabled when vmExists is true', () => {
      render(
        <Controller
          {...defaultProps}
          config={{ ...defaultProps.config, vmExists: true }}
        />
      );

      const controllerTypeButton = screen.getByRole('button', {
        name: 'LSI Logic Parallel',
      });
      expect(controllerTypeButton).toBeDisabled();
    });
  });

  describe('Add Volume Button', () => {
    it('renders and clicks add volume button', async () => {
      const addDisk = jest.fn();
      render(
        <Controller
          {...defaultProps}
          addDisk={addDisk}
          controllerVolumes={[]}
        />
      );

      const addButton = screen.getByRole('button', { name: 'Add volume' });
      expect(addButton).toBeInTheDocument();
      await act(async () => {
        await userEvent.click(addButton);
      });
      expect(addDisk).toHaveBeenCalledTimes(1);
    });

    it('shows Add another volume when volumes exist', () => {
      render(<Controller {...defaultProps} />);
      expect(
        screen.getByRole('button', { name: 'Add another volume' })
      ).toBeInTheDocument();
    });

    it('is disabled with tooltip when addDiskEnabled is false', async () => {
      render(<Controller {...defaultProps} addDiskEnabled={false} />);
      const addButton = screen.getByRole('button', {
        name: 'Add another volume',
      });
      expect(addButton).toHaveAttribute('aria-disabled', 'true');
      await act(async () => {
        await userEvent.hover(addButton);
        jest.advanceTimersByTime(1000);
      });
      expect(
        screen.getByText(/Maximum number of disks/)
      ).toBeInTheDocument();
    });

    it('is disabled with tooltip when vmExists is true', async () => {
      render(
        <Controller
          {...defaultProps}
          config={{ ...defaultProps.config, vmExists: true }}
        />
      );
      const addButton = screen.getByRole('button', {
        name: 'Add another volume',
      });
      expect(addButton).toHaveAttribute('aria-disabled', 'true');
      await act(async () => {
        await userEvent.hover(addButton);
        jest.advanceTimersByTime(1000);
      });
      expect(
        screen.getByText('Cannot add volumes to an existing VM')
      ).toBeInTheDocument();
    });

    it('is enabled when addDiskEnabled is true and vmExists is false', () => {
      render(<Controller {...defaultProps} addDiskEnabled={true} />);

      const addButton = screen.getByRole('button', {
        name: 'Add another volume',
      });
      expect(addButton).not.toBeDisabled();
    });
  });

  describe('Remove controller Button', () => {
    it('renders and clicks remove controller button', async () => {
      const removeController = jest.fn();
      render(
        <Controller {...defaultProps} removeController={removeController} />
      );

      const deleteButton = screen.getByRole('button', {
        name: 'Remove controller',
      });
      expect(deleteButton).toBeInTheDocument();
      await act(async () => {
        await userEvent.click(deleteButton);
      });
      expect(removeController).toHaveBeenCalledTimes(1);
    });

    it('is disabled when vmExists is true', () => {
      render(
        <Controller
          {...defaultProps}
          config={{ ...defaultProps.config, vmExists: true }}
        />
      );

      const deleteButton = screen.getByRole('button', {
        name: 'Remove controller',
      });
      expect(deleteButton).toBeDisabled();
    });

    it('is enabled when vmExists is false', () => {
      render(<Controller {...defaultProps} />);

      const deleteButton = screen.getByRole('button', {
        name: 'Remove controller',
      });
      expect(deleteButton).not.toBeDisabled();
    });
  });

  describe('Disk Components', () => {
    it('renders all disks from controllerVolumes', () => {
      const volumes = [
        {
          thin: true,
          name: 'Hard disk 1',
          mode: 'persistent',
          controllerKey: 1000,
          sizeGb: 10,
          key: 'disk-1',
        },
        {
          thin: false,
          name: 'Hard disk 2',
          mode: 'independent_persistent',
          controllerKey: 1000,
          sizeGb: 20,
          key: 'disk-2',
        },
      ];

      render(<Controller {...defaultProps} controllerVolumes={volumes} />);

      expect(screen.getByText('Hard disk 1')).toBeInTheDocument();
      expect(screen.getByText('Hard disk 2')).toBeInTheDocument();
    });
  });

  it('handles empty datastores array', () => {
    render(<Controller {...defaultProps} datastores={[]} />);
    expect(screen.getByText('Controller')).toBeInTheDocument();
  });

  it('handles empty storage pods array', () => {
    render(<Controller {...defaultProps} storagePods={[]} />);
    expect(screen.getByText('Controller')).toBeInTheDocument();
  });

  describe('Datastores and Storage Pods', () => {
    it('formats datastores stats correctly', async () => {
      const datastores = [
        {
          name: 'datastore1',
          id: 'ds-1',
          capacity: 2199023255552,
          freespace: 1073741824000,
          uncommitted: 0,
        },
      ];

      render(<Controller {...defaultProps} datastores={datastores} />);
      await act(async () => {
        await userEvent.click(
          screen.getByRole('button', { name: 'Data store select' })
        );
        jest.advanceTimersByTime(1000);
      });
      expect(
        screen.getByText(
          'datastore1 (free: 1.00 TB, prov: 1.00 TB, total: 2.00 TB)'
        )
      ).toBeInTheDocument();
    });

    it('formats storage pods stats correctly', async () => {
      const storagePods = [
        {
          name: 'pod1',
          id: 'pod-1',
          capacity: 5497021267968,
          freespace: 2748510633984,
        },
      ];

      render(<Controller {...defaultProps} storagePods={storagePods} />);
      await act(async () => {
        await userEvent.click(
          screen.getByRole('button', { name: 'Storage pod select' })
        );
        jest.advanceTimersByTime(1000);
      });
      expect(
        screen.getByText('pod1 (free: 2.5 TB, prov: 2.5 TB, total: 5.00 TB)')
      ).toBeInTheDocument();
    });

    it('passes datastores status and error to Disk components', async () => {
      render(
        <Controller
          {...defaultProps}
          datastoresStatus="ERROR"
          datastoresError="Error message"
        />
      );
      const errorButton = screen.getByRole('button', {
        name: 'popover for datastores',
      });
      await act(async () => {
        await userEvent.click(errorButton);
        jest.advanceTimersByTime(1000);
      });
      expect(screen.getByText('Error message')).toBeInTheDocument();
    });

    it('passes storage pods status and error to Disk components', async () => {
      render(
        <Controller
          {...defaultProps}
          storagePodsStatus="ERROR"
          storagePodsError="Storage pod error"
        />
      );
      const errorButton = screen.getByRole('button', {
        name: 'popover for storagePods',
      });
      await act(async () => {
        await userEvent.click(errorButton);
        jest.advanceTimersByTime(1000);
      });
      expect(screen.getByText('Storage pod error')).toBeInTheDocument();
    });
  });

  describe('Update Controller', () => {
    it('calls updateController when controller type changes', async () => {
      const updateController = jest.fn();
      render(
        <Controller {...defaultProps} updateController={updateController} />
      );
      const controllerTypeButton = screen.getByRole('button', {
        name: 'LSI Logic Parallel',
      });
      await act(async () => {
        await userEvent.click(controllerTypeButton);
      });
      await act(async () => {
        await userEvent.click(
          screen.getByRole('option', { name: 'NVME Controller' })
        );
        jest.advanceTimersByTime(1000);
      });
      expect(updateController).toHaveBeenCalledWith({
        type: 'VirtualNVMEController',
      });
    });
  });

  describe('Update Disk', () => {
    it('calls updateDisk with correct parameters', async () => {
      const updateDisk = jest.fn();
      const volumes = [
        {
          thin: true,
          name: 'Test Disk',
          mode: 'persistent',
          controllerKey: 1000,
          sizeGb: 10,
          key: 'test-key',
        },
      ];

      render(
        <Controller
          {...defaultProps}
          controllerVolumes={volumes}
          updateDisk={updateDisk}
        />
      );
      const podSelect = screen.getByRole('button', {
        name: 'Storage pod select',
      });
      await act(async () => {
        await userEvent.click(podSelect);
      });
      await act(async () => {
        await userEvent.click(
          screen.getByRole('option', {
            name: 'LX-DC1-EXAMPLE (free: 4.3 TB, prov: 690 GB, total: 5.00 TB)',
          })
        );
        jest.advanceTimersByTime(1000);
      });
      expect(updateDisk).toHaveBeenNthCalledWith(1, 'test-key', {
        storagePod: 'LX-DC1-EXAMPLE',
      });
      expect(updateDisk).toHaveBeenNthCalledWith(2, 'test-key', {
        datastore: null,
      });
      const datastoreSelect = screen.getByRole('button', {
        name: 'Data store select',
      });
      await act(async () => {
        await userEvent.click(datastoreSelect);
      });
      await act(async () => {
        await userEvent.click(
          screen.getByRole('option', {
            name:
              'FC0001_LX_DC1_EXAMPLE_PROD_01 (free: 350 GB, prov: 4.9 TB, total: 2.00 TB)',
          })
        );
        jest.advanceTimersByTime(1000);
      });
      expect(updateDisk).toHaveBeenNthCalledWith(3, 'test-key', {
        datastore: 'FC0001_LX_DC1_EXAMPLE_PROD_01',
      });
      expect(updateDisk).toHaveBeenNthCalledWith(4, 'test-key', {
        storagePod: null,
      });
    });
  });

  describe('Remove volume', () => {
    it('calls removeDisk with correct disk key', async () => {
      const removeDisk = jest.fn();
      const volumes = [
        {
          thin: true,
          name: 'Test Disk',
          mode: 'persistent',
          controllerKey: 1000,
          sizeGb: 10,
          key: 'test-key',
        },
      ];

      render(
        <Controller
          {...defaultProps}
          controllerVolumes={volumes}
          removeDisk={removeDisk}
        />
      );

      const deleteButton = screen.getByRole('button', {
        name: 'Remove volume',
      });
      await act(async () => {
        await userEvent.click(deleteButton);
        jest.advanceTimersByTime(1000);
      });
      expect(removeDisk).toHaveBeenCalledWith('test-key');
    });
  });
});
