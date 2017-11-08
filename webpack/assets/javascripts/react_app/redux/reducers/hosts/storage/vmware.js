/* eslint no-case-declarations:0 */
/* eslint no-case-declarations:0 */
import { difference, head } from 'lodash';
import Immutable from 'seamless-immutable';
import uuidV1 from 'uuid/v1';

import {
  STORAGE_VMWARE_ADD_CONTROLLER,
  STORAGE_VMWARE_ADD_DISK,
  STORAGE_VMWARE_REMOVE_DISK,
  STORAGE_VMWARE_REMOVE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_DISK,
  STORAGE_VMWARE_INIT,
} from '../../../consts';

const initialState = Immutable({
  controllers: [],
});

const availableControllerKeys = [1000, 1001, 1002, 1003, 1004];

const getAvailableKey = controllers =>
  head(difference(availableControllerKeys, controllers.map(c => c.key)));

export default (state = initialState, { type, payload }) => {
  switch (type) {
    case STORAGE_VMWARE_ADD_CONTROLLER:
      const availableKey = getAvailableKey(state.controllers);

      // controller key is assigned here using getAvailableKey
      return state
        .update('controllers', ctrls =>
          ctrls.concat(Object.assign({}, payload.controller, { key: availableKey })))
        .update('volumes', volumes => (
          volumes.concat(Object.assign(
            {},
            payload.volume,
            { controllerKey: availableKey },
            { key: uuidV1() },
          ))
        ));
    case STORAGE_VMWARE_ADD_DISK:
      return state.set(
        'volumes',
        state.volumes.concat({
          ...payload.data,
          key: uuidV1(),
          controllerKey: payload.controllerKey,
        }),
      );
    case STORAGE_VMWARE_REMOVE_CONTROLLER:
      return state
        .update('controllers', ctrls => ctrls.filter(ctrl => ctrl.key !== payload.controllerKey))
        .update('volumes', volumes =>
          volumes.filter(volume => volume.controllerKey !== payload.controllerKey));
    case STORAGE_VMWARE_UPDATE_CONTROLLER:
      return state.updateIn(['controllers', payload.idx], controller =>
        Object.assign({}, controller, payload.newValues));
    case STORAGE_VMWARE_UPDATE_DISK:
      return state.set(
        'volumes',
        state.volumes.map(v => (
          v.key === payload.key ? Object.assign({}, v, payload.newValues) : v
        )),
      );
    case STORAGE_VMWARE_REMOVE_DISK:
      return state.set('volumes', state.volumes.filter(v => v.key !== payload.key));
    case STORAGE_VMWARE_INIT:
      return initialState
        .set('config', payload.config)
        .setIn(['config', 'addControllerEnabled'], !!getAvailableKey(payload.controllers))
        .set('controllers', payload.controllers)
        .set('paramsScope', payload.config.paramsScope)
        .set('volumes', payload.volumes.map(volume => ({ ...volume, key: uuidV1() })));
    default:
      return state;
  }
};
