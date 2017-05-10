import {
  STORAGE_VMWARE_ADD_CONTROLLER,
  STORAGE_VMWARE_ADD_DISK,
  STORAGE_VMWARE_REMOVE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_CONTROLLER,
  STORAGE_VMWARE_REMOVE_DISK,
  STORAGE_VMWARE_UPDATE_DISK,
  STORAGE_VMWARE_INIT
} from '../../../consts';
import {
  defaultConrollerAttributes,
  getDefaultDiskAttributes
} from './vmware.consts';

export const updateDisk = (key, newValues) => {
  return {
    type: STORAGE_VMWARE_UPDATE_DISK,
    payload: {
      key,
      newValues
    }
  };
};

export const initController = (config, controllers, volumes) => {
  return {
    type: STORAGE_VMWARE_INIT,
    payload: {
      config,
      controllers: controllers || defaultConrollerAttributes,
      volumes: volumes || getDefaultDiskAttributes()
    }
  };
};

export const addController = data => ({
  type: STORAGE_VMWARE_ADD_CONTROLLER,
  payload: {
    controller: defaultConrollerAttributes,
    volume: getDefaultDiskAttributes()
  }
});

export const updateController = (idx, newValues) => ({
  type: STORAGE_VMWARE_UPDATE_CONTROLLER,
  payload: {
    idx,
    newValues
  }
});

export const removeDisk = key => ({
  type: STORAGE_VMWARE_REMOVE_DISK,
  payload: {
    key
  }
});

export const removeController = controllerKey => ({
  type: STORAGE_VMWARE_REMOVE_CONTROLLER,
  payload: { controllerKey }
});

export const addDisk = controllerKey => ({
  type: STORAGE_VMWARE_ADD_DISK,
  payload: {
    controllerKey,
    data: getDefaultDiskAttributes()
  }
});
