import {
  VMWARE_CLUSTER_CHANGE,
  STORAGE_VMWARE_INIT,
  STORAGE_VMWARE_DATASTORES_REQUEST,
  STORAGE_VMWARE_DATASTORES_SUCCESS,
  STORAGE_VMWARE_DATASTORES_FAILURE,
  STORAGE_VMWARE_STORAGEPODS_REQUEST,
  STORAGE_VMWARE_STORAGEPODS_SUCCESS,
  STORAGE_VMWARE_STORAGEPODS_FAILURE,
} from '../../../consts';

import {
  defaultControllerAttributes,
  getDefaultDiskAttributes,
} from './vmware.consts';

export const datastoresUrl = 'test.com/datastores';
export const storagePodsUrl = 'test.com/storage_pods';

const controllerTypes = {
  VirtualBusLogicController: 'Bus Logic Parallel',
  VirtualLsiLogicController: 'LSI Logic Parallel',
  VirtualLsiLogicSASController: 'LSI Logic SAS',
  ParaVirtualSCSIController: 'VMware Paravirtual',
};

const diskModeTypes = {
  persistent: 'Persistent',
  independent_persistent: 'Independent - Persistent',
  independent_nonpersistent: 'Independent - Nonpersistent',
};

export const basicConfig = {
  vmExists: false,
  controllerTypes,
  diskModeTypes,
  paramsScope: 'host[storageParams]',
  datastoresUrl,
  storagePodsUrl,
};

export const initAction = {
  type: STORAGE_VMWARE_INIT,
  payload: {
    config: basicConfig,
    controllers: defaultControllerAttributes,
    volumes: getDefaultDiskAttributes,
    cluster: 'cluster',
  },
};

export const changeClusterAction = {
  type: VMWARE_CLUSTER_CHANGE,
  payload: {
    cluster: 'newCluster',
  },
};

export const state1 = {
  hosts: {
    storage: {
      vmware: {
        config: basicConfig,
        cluster: 'cluster',
      },
    },
  },
};

export const fetchDatastoreParams = {
  requestAction: STORAGE_VMWARE_DATASTORES_REQUEST,
  successAction: STORAGE_VMWARE_DATASTORES_SUCCESS,
  failedAction: STORAGE_VMWARE_DATASTORES_FAILURE,
  url: datastoresUrl,
  item: { params: { cluster_id: 'cluster' } },
};

export const fetchStoragePodsParams = {
  requestAction: STORAGE_VMWARE_STORAGEPODS_REQUEST,
  successAction: STORAGE_VMWARE_STORAGEPODS_SUCCESS,
  failedAction: STORAGE_VMWARE_STORAGEPODS_FAILURE,
  url: storagePodsUrl,
  item: { params: { cluster_id: 'cluster' } },
};
