import {
  INTERFACES_INITIALIZE,
  INTERFACES_ADD_INTERFACE,
  INTERFACES_UPDATE_INTERFACE,
  INTERFACES_REMOVE_INTERFACE,
  INTERFACES_SET_PRIMARY_INTERFACE_NAME,
  INTERFACES_SET_PRIMARY_INTERFACE,
  INTERFACES_SET_PROVISION_INTERFACE,
} from '../../consts';

export const initializeInterfaces = interfaceValues => ({
  type: INTERFACES_INITIALIZE,
  payload: { interfaces: interfaceValues },
});

export const addInterface = (data = {}) => ({
  type: INTERFACES_ADD_INTERFACE,
  payload: { data },
});

export const updateInterface = (id, newValues) => ({
  type: INTERFACES_UPDATE_INTERFACE,
  payload: {
    id,
    newValues,
  },
});

export const removeInterface = id => ({
  type: INTERFACES_REMOVE_INTERFACE,
  payload: { id },
});

export const setPrimaryInterface = id => ({
  type: INTERFACES_SET_PRIMARY_INTERFACE,
  payload: { id },
});

export const setProvisionInterface = id => ({
  type: INTERFACES_SET_PROVISION_INTERFACE,
  payload: { id },
});

export const setPrimaryInterfaceName = newName => ({
  type: INTERFACES_SET_PRIMARY_INTERFACE_NAME,
  payload: { newName },
});
