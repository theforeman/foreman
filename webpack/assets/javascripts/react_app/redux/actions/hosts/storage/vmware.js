import {
  VMWARE_CLUSTER_CHANGE,
  STORAGE_VMWARE_ADD_CONTROLLER,
  STORAGE_VMWARE_ADD_DISK,
  STORAGE_VMWARE_REMOVE_CONTROLLER,
  STORAGE_VMWARE_UPDATE_CONTROLLER,
  STORAGE_VMWARE_REMOVE_DISK,
  STORAGE_VMWARE_UPDATE_DISK,
  STORAGE_VMWARE_INIT,
  STORAGE_VMWARE_DATASTORES,
  STORAGE_VMWARE_STORAGEPODS,
} from '../../../consts';
import { get } from '../../../API';
import {
  defaultControllerAttributes,
  getDefaultDiskAttributes,
} from './vmware.consts';

export const updateDisk = (key, newValues) => ({
  type: STORAGE_VMWARE_UPDATE_DISK,
  payload: {
    key,
    newValues,
  },
});

export const initController =
  (config, cluster, controllers, volumes) => (dispatch) => {
    dispatch({
      type: STORAGE_VMWARE_INIT,
      payload: {
        config,
        controllers: controllers || defaultControllerAttributes,
        volumes: volumes || getDefaultDiskAttributes,
        cluster,
      },
    });
    if (cluster) {
      dispatch(fetchDatastores(config.datastoresUrl, cluster));
      dispatch(fetchStoragePods(config.storagePodsUrl, cluster));
    }
  };

export const changeCluster = (newCluster) => (dispatch, getState) => {
  const { config } = getState().hosts.storage.vmware;
  if (newCluster === '') newCluster = null;

  dispatch({
    type: VMWARE_CLUSTER_CHANGE,
    payload: {
      cluster: newCluster,
    },
  });
  if (newCluster) {
    dispatch(fetchDatastores(config.datastoresUrl, newCluster));
    dispatch(fetchStoragePods(config.storagePodsUrl, newCluster));
  }
};

const fetchStorages = (url, cluster, key) =>
  get({
    key,
    url,
    payload: { params: { cluster_id: cluster } },
  });

export const fetchDatastores = (url, cluster) =>
  fetchStorages(url, cluster, STORAGE_VMWARE_DATASTORES);

export const fetchStoragePods = (url, cluster) =>
  fetchStorages(url, cluster, STORAGE_VMWARE_STORAGEPODS);

export const addController = (data) => ({
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

export const removeDisk = (key) => ({
  type: STORAGE_VMWARE_REMOVE_DISK,
  payload: {
    key,
  },
});

export const removeController = (controllerKey) => ({
  type: STORAGE_VMWARE_REMOVE_CONTROLLER,
  payload: { controllerKey },
});

export const addDisk = (controllerKey) => ({
  type: STORAGE_VMWARE_ADD_DISK,
  payload: {
    controllerKey,
    data: getDefaultDiskAttributes,
  },
});
