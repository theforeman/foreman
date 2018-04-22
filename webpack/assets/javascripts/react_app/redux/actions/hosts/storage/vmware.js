import {
  STORAGE_VMWARE_ADD_CONTROLLER,
  STORAGE_VMWARE_ADD_DISK,
  STORAGE_VMWARE_REMOVE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_CONTROLLER,
  STORAGE_VMWARE_REMOVE_DISK,
  STORAGE_VMWARE_UPDATE_DISK,
  STORAGE_VMWARE_INIT,
  STORAGE_VMWARE_DATASTORES_REQUEST,
  STORAGE_VMWARE_DATASTORES_SUCCESS,
  STORAGE_VMWARE_DATASTORES_FAILURE,
  STORAGE_VMWARE_STORAGEPODS_REQUEST,
  STORAGE_VMWARE_STORAGEPODS_SUCCESS,
  STORAGE_VMWARE_STORAGEPODS_FAILURE,
} from '../../../consts';
import { defaultControllerAttributes, getDefaultDiskAttributes } from './vmware.consts';
import { ajaxRequestAction } from '../../common';

export const updateDisk = (key, newValues) => ({
  type: STORAGE_VMWARE_UPDATE_DISK,
  payload: {
    key,
    newValues,
  },
});

export const initController = (config, controllers, volumes) => (dispatch) => {
  dispatch({
    type: STORAGE_VMWARE_INIT,
    payload: {
      config,
      controllers: controllers || defaultControllerAttributes,
      volumes: volumes || getDefaultDiskAttributes,
    },
  });
};

export const fetchDatastores = url => (dispatch) => {
  ajaxRequestAction({
    dispatch,
    requestAction: STORAGE_VMWARE_DATASTORES_REQUEST,
    successAction: STORAGE_VMWARE_DATASTORES_SUCCESS,
    failedAction: STORAGE_VMWARE_DATASTORES_FAILURE,
    url,
  });
};

export const fetchStoragePods = url => (dispatch) => {
  ajaxRequestAction({
    dispatch,
    requestAction: STORAGE_VMWARE_STORAGEPODS_REQUEST,
    successAction: STORAGE_VMWARE_STORAGEPODS_SUCCESS,
    failedAction: STORAGE_VMWARE_STORAGEPODS_FAILURE,
    url,
  });
};

export const addController = data => ({
  type: STORAGE_VMWARE_ADD_CONTROLLER,
  payload: {
    controller: defaultControllerAttributes,
    volume: getDefaultDiskAttributes,
  },
});

export const updateController = (idx, newValues) => ({
  type: STORAGE_VMWARE_UPDATE_CONTROLLER,
  payload: {
    idx,
    newValues,
  },
});

export const removeDisk = key => ({
  type: STORAGE_VMWARE_REMOVE_DISK,
  payload: {
    key,
  },
});

export const removeController = controllerKey => ({
  type: STORAGE_VMWARE_REMOVE_CONTROLLER,
  payload: { controllerKey },
});

export const addDisk = controllerKey => ({
  type: STORAGE_VMWARE_ADD_DISK,
  payload: {
    controllerKey,
    data: getDefaultDiskAttributes,
  },
});
