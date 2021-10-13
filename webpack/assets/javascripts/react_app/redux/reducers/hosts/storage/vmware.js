/* eslint no-case-declarations:0 */
/* eslint no-case-declarations:0 */
import { difference, head } from 'lodash';
import Immutable from 'seamless-immutable';
import uuidV1 from 'uuid/v1';

import {
  VMWARE_CLUSTER_CHANGE,
  STORAGE_VMWARE_ADD_CONTROLLER,
  STORAGE_VMWARE_ADD_DISK,
  STORAGE_VMWARE_REMOVE_DISK,
  STORAGE_VMWARE_REMOVE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_DISK,
  STORAGE_VMWARE_INIT,
  STORAGE_VMWARE_DATASTORES_REQUEST,
  STORAGE_VMWARE_DATASTORES_SUCCESS,
  STORAGE_VMWARE_DATASTORES_FAILURE,
  STORAGE_VMWARE_STORAGEPODS_REQUEST,
  STORAGE_VMWARE_STORAGEPODS_SUCCESS,
  STORAGE_VMWARE_STORAGEPODS_FAILURE,
} from '../../../consts';

const initialState = Immutable({
  controllers: [],
  volumes: [],
});

const availableControllerKeys = [1000, 1001, 1002, 1003, 1004];

const getAvailableKey = (controllers) =>
  head(
    difference(
      availableControllerKeys,
      controllers.map((c) => c.key)
    )
  );

export default (state = initialState, { type, payload, response }) => {
  switch (type) {
    case VMWARE_CLUSTER_CHANGE:
      return state.set('cluster', payload.cluster);
    case STORAGE_VMWARE_ADD_CONTROLLER:
      const availableKey = getAvailableKey(state.controllers);

      // controller key is assigned here using getAvailableKey
      return state
        .update('controllers', (ctrls) =>
          ctrls.concat(
            Object.assign({}, payload.controller, { key: availableKey })
          )
        )
        .update('volumes', (volumes) =>
          volumes.concat(
            Object.assign(
              {},
              payload.volume,
              { controllerKey: availableKey },
              { key: uuidV1() }
            )
          )
        );
    case STORAGE_VMWARE_ADD_DISK:
      return state.set(
        'volumes',
        state.volumes.concat({
          ...payload.data,
          key: uuidV1(),
          controllerKey: payload.controllerKey,
        })
      );
    case STORAGE_VMWARE_REMOVE_CONTROLLER:
      return state
        .update('controllers', (ctrls) =>
          ctrls.filter((ctrl) => ctrl.key !== payload.controllerKey)
        )
        .update('volumes', (volumes) =>
          volumes.filter(
            (volume) => volume.controllerKey !== payload.controllerKey
          )
        );
    case STORAGE_VMWARE_UPDATE_CONTROLLER:
      return state.updateIn(['controllers', payload.idx], (controller) =>
        Object.assign({}, controller, payload.newValues)
      );
    case STORAGE_VMWARE_UPDATE_DISK:
      return state.set(
        'volumes',
        state.volumes.map((v) =>
          v.key === payload.key ? Object.assign({}, v, payload.newValues) : v
        )
      );
    case STORAGE_VMWARE_REMOVE_DISK:
      return state.set(
        'volumes',
        state.volumes.filter((v) => v.key !== payload.key)
      );
    case STORAGE_VMWARE_INIT:
      const newState = {
        controllers: payload.controllers,
        paramsScope: payload.config.paramsScope,
        datastores: [],
        datastoresLoading: false,
        datastoresError: undefined,
        storagePods: [],
        storagePodsLoading: false,
        storagePodsError: undefined,
        volumes: payload.volumes.map((volume) => ({
          ...volume,
          key: uuidV1(),
        })),
        cluster: payload.cluster,
      };
      return initialState
        .set('config', payload.config)
        .setIn(
          ['config', 'addControllerEnabled'],
          !!getAvailableKey(payload.controllers)
        )
        .merge(newState);
    case STORAGE_VMWARE_DATASTORES_REQUEST:
      return state.merge({
        datastoresError: undefined,
        datastores: [],
        datastoresLoading: true,
      });
    case STORAGE_VMWARE_DATASTORES_SUCCESS:
      return state
        .set('datastores', response.results)
        .set('datastoresLoading', false);
    case STORAGE_VMWARE_DATASTORES_FAILURE:
      return state.set('datastoresError', response.message);
    case STORAGE_VMWARE_STORAGEPODS_REQUEST:
      return state.merge({
        storagePodsError: undefined,
        storagePods: [],
        storagePodsLoading: true,
      });
    case STORAGE_VMWARE_STORAGEPODS_SUCCESS:
      return state.merge({
        storagePods: response.results,
        storagePodsLoading: false,
      });
    case STORAGE_VMWARE_STORAGEPODS_FAILURE:
      return state.set('storagePodsError', response.message);
    default:
      return state;
  }
};
