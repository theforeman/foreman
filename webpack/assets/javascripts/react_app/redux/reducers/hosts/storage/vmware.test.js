import uuidV1 from 'uuid/v1';

import * as types from '../../../consts';

import {
  diskKey,
  initialState,
  controllerAttributes,
  diskAttributes,
  stateWithController,
  stateWithRemovedController,
} from './vmware.fixtures';

import reducer from './vmware';

jest.mock('uuid/v1');
let uuidCounter = 0;
uuidV1.mockImplementation(() => `uuid-${++uuidCounter}`);

describe('vmware storage reducer', () => {
  it('returns the initial state', () => {
    expect(reducer(undefined, {})).toEqual(initialState);
  });

  it('handles cluster change', () => {
    expect(
      reducer(initialState, {
        type: types.VMWARE_CLUSTER_CHANGE,
        payload: { cluster: 'testCluster' },
      })
    ).toEqual({ ...initialState, cluster: 'testCluster' });
  });

  describe('STORAGE_VMWARE_ADD_CONTROLLER', () => {
    it('adds controller to initialState', () => {
      expect(
        reducer(initialState, {
          type: types.STORAGE_VMWARE_ADD_CONTROLLER,
          payload: {
            controller: controllerAttributes,
            volume: diskAttributes,
          },
        })
      ).toMatchSnapshot();
    });

    it('adds another controller', () => {
      expect(
        reducer(stateWithController, {
          type: types.STORAGE_VMWARE_ADD_CONTROLLER,
          payload: {
            controller: controllerAttributes,
            volume: diskAttributes,
          },
        })
      ).toMatchSnapshot();
    });

    it('adds another controller to fill after removed one', () => {
      expect(
        reducer(stateWithRemovedController, {
          type: types.STORAGE_VMWARE_ADD_CONTROLLER,
          payload: {
            controller: controllerAttributes,
            volume: diskAttributes,
          },
        })
      ).toMatchSnapshot();
    });
  });

  describe('STORAGE_VMWARE_ADD_DISK', () => {
    it('adds volume', () => {
      expect(
        reducer(stateWithController, {
          type: types.STORAGE_VMWARE_ADD_DISK,
          payload: {
            controllerKey: 1000,
            data: diskAttributes,
          },
        })
      ).toMatchSnapshot();
    });

    it('renumbers volumes after deletion', () => {
      const stateWith2Disks = reducer(stateWithController, {
        type: types.STORAGE_VMWARE_ADD_DISK,
        payload: { controllerKey: 1000, data: diskAttributes },
      });
      expect(stateWith2Disks.volumes).toHaveLength(2);

      const stateAfterRemove = reducer(stateWith2Disks, {
        type: types.STORAGE_VMWARE_REMOVE_DISK,
        payload: { key: diskKey },
      });
      expect(stateAfterRemove.volumes).toHaveLength(1);
      expect(stateAfterRemove.volumes[0].name).toEqual('Hard disk 1');
    });

    it('keeps sequential names after removing middle disks', () => {
      let state = stateWithController;

      state = reducer(state, {
        type: types.STORAGE_VMWARE_ADD_DISK,
        payload: { controllerKey: 1000, data: diskAttributes },
      });
      state = reducer(state, {
        type: types.STORAGE_VMWARE_ADD_DISK,
        payload: { controllerKey: 1000, data: diskAttributes },
      });
      state = reducer(state, {
        type: types.STORAGE_VMWARE_ADD_DISK,
        payload: { controllerKey: 1000, data: diskAttributes },
      });
      expect(state.volumes).toHaveLength(4);
      expect(state.volumes.map(vol => vol.name)).toEqual([
        'Hard disk 1',
        'Hard disk 2',
        'Hard disk 3',
        'Hard disk 4',
      ]);

      state = reducer(state, {
        type: types.STORAGE_VMWARE_REMOVE_DISK,
        payload: { key: state.volumes[1].key },
      });
      state = reducer(state, {
        type: types.STORAGE_VMWARE_REMOVE_DISK,
        payload: { key: state.volumes[1].key },
      });
      expect(state.volumes).toHaveLength(2);
      expect(state.volumes.map(vol => vol.name)).toEqual([
        'Hard disk 1',
        'Hard disk 2',
      ]);
    });
  });

  describe('STORAGE_VMWARE_INIT', () => {
    it('normalizes Hard disk to Hard disk 1 on init', () => {
      const result = reducer(initialState, {
        type: types.STORAGE_VMWARE_INIT,
        payload: {
          config: { controllerTypes: {} },
          controllers: [{ type: 'VirtualLsiLogicController', key: 1000 }],
          volumes: [
            { name: 'Hard disk', controllerKey: 1000, sizeGb: 10 },
          ],
          cluster: 'TestCluster',
        },
      });
      expect(result.volumes[0].name).toEqual('Hard disk 1');
    });
  });

  describe('STORAGE_VMWARE_UPDATE_DISK', () => {
    it('update volume', () => {
      const result = reducer(stateWithController, {
        type: types.STORAGE_VMWARE_UPDATE_DISK,
        payload: {
          key: diskKey,
          newValues: { sizeGb: 15 },
        },
      });
      expect(result.volumes).toEqual([
        { ...stateWithController.volumes[0], sizeGb: 15 },
      ]);
    });
  });
});
