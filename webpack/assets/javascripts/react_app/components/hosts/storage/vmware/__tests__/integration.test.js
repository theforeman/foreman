import React from 'react';
import { screen, act } from '@testing-library/react';
import '@testing-library/jest-dom';
import userEvent from '@testing-library/user-event';

import { rtlHelpers } from '../../../../../common/rtlTestHelpers';
import { vmwareData, hiddenFieldValue } from './StorageContainer.fixtures';
import StorageContainer from '../';

describe('StorageContainer integration test', () => {
  let store;
  let container;
  jest.useFakeTimers();
  beforeEach(() => {
    const initialState = {
      hosts: {
        storage: {
          vmware: {
            controllers: [],
            config: {},
            cluster: '',
            volumes: [],
            datastores: [],
            datastoresLoading: false,
            datastoresError: undefined,
            storagePods: [],
            storagePodsLoading: false,
            storagePodsError: undefined,
          },
        },
      },
    };

    const renderResult = rtlHelpers.renderWithStore(
      <StorageContainer data={vmwareData} />,
      initialState
    );
    store = renderResult.store;
    container = renderResult.container;
  });

  it('render hidden field correctly', () => {
    const hiddenField = container.querySelector('#controller_hidden');
    expect(hiddenField).toBeInTheDocument();
    expect(JSON.parse(hiddenField.value)).toEqual(hiddenFieldValue);
  });

  it('adds a disk when button is clicked', async () => {
    const diskContainers = container.querySelectorAll('.disk-container');
    expect(diskContainers).toHaveLength(1);

    const addButton = screen.getByRole('button', {
      name: /add another volume/i,
    });

    await act(async () => {
      await userEvent.click(addButton);
    });

    const updatedContainers = container.querySelectorAll('.disk-container');
    expect(updatedContainers).toHaveLength(2);
  });

  it('adds a controller when button is clicked', async () => {
    const controllerContainers = container.querySelectorAll(
      '.controller-container'
    );
    expect(controllerContainers).toHaveLength(1);

    const addButton = screen.getByRole('button', {
      name: /create another controller/i,
    });

    await act(async () => {
      await userEvent.click(addButton);
    });

    const updatedContainers = container.querySelectorAll(
      '.controller-container'
    );
    expect(updatedContainers).toHaveLength(2);
  });

  it('removes controller when one is selected', async () => {
    const controllerContainers = container.querySelectorAll(
      '.controller-container'
    );
    expect(controllerContainers).toHaveLength(1);

    const removeButton = screen.getByRole('button', {
      name: /remove controller/i,
    });
    await userEvent.click(removeButton);

    const updatedContainers = container.querySelectorAll(
      '.controller-container'
    );
    expect(updatedContainers).toHaveLength(0);
  });

  it('changes controller type when one is selected', async () => {
    const getControllerType = () =>
      store.getState().hosts.storage.vmware.controllers[0].type;

    expect(getControllerType()).toEqual('VirtualLsiLogicController');
    const controllerTypeButton = screen.getByRole('button', {
      name: 'LSI Logic Parallel',
    });
    expect(controllerTypeButton).toBeInTheDocument();
    await act(async () => {
      await userEvent.click(controllerTypeButton);
    });
    await act(async () => {
      await userEvent.click(
        screen.getByRole('option', { name: 'VMware Paravirtual' })
      );
    });
    act(() => jest.advanceTimersByTime(1000));
    expect(getControllerType()).toEqual('ParaVirtualSCSIController');
  });
});
