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
uuidV1.mockImplementation(() => '1547e1c0-309a-11e9-98f5-5f761412a4c2');

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
