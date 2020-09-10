/* eslint-disable */
import {
  defaultDiskModeTypes,
  datastoresStubData,
  storagePodsStubData
} from '../controller/disk/disk.fixtures';

const controllerTypes = {
  VirtualBusLogicController: 'Bus Logic Parallel',
  VirtualLsiLogicController: 'LSI Logic Parallel',
  VirtualLsiLogicSASController: 'LSI Logic SAS',
  ParaVirtualSCSIController: 'VMware Paravirtual',
}

export const storageDomainResponse = {
  results: [
    {
      name: 'MyDatastore',
      id: 'datastore-608634',
      capacity: 2199023255552,
      freespace: 659551158272,
      uncommitted: 4076735943455,
    },
  ],
}

export const storagePodResponse = {
  results: [
    {
      name: 'MyStoragePod',
      id: 'group-p859969',
      capacity: 5497021267968,
      freespace: 4829829136384,
    },
  ],
}

export const vmwareData = {
  config: {
    controllerTypes,
    diskModeTypes: defaultDiskModeTypes,
    storagePods: storagePodsStubData,
    datastores: datastoresStubData('cfme'),
  },
  volumes: [
    {
      thin: true,
      name: 'Hard disk',
      mode: 'persistent',
      controllerKey: 1000,
      sizeGb: 10,
    },
  ],
  controllers: [{ type: 'VirtualLsiLogicController', key: 1000 }],
  cluster: 'Foreman_Cluster',
};

export const hiddenFieldValue = {
  scsiControllers: [{ key: 1000, type: 'VirtualLsiLogicController' }],
  volumes: [
    {
      controllerKey: 1000,
      mode: 'persistent',
      name: 'Hard disk',
      sizeGb: 10,
      thin: true,
    },
  ],
};

/* storybook data */
export const state1 = {
  config: {
    datastoresUrl: '/api/v2/compute_resources/1/available_storage_domains',
    storagePodsUrl: '/api/v2/compute_resources/1/available_storage_pods',
    controllerTypes,
    diskModeTypes: defaultDiskModeTypes,
    storagePods: storagePodsStubData,
    datastores: datastoresStubData('org'),
    paramsScope: 'abc',
  },
  volumes: [
    {
      thin: true,
      name: 'Hard disk',
      mode: 'persistent',
      controllerKey: 1000,
      sizeGb: 10,
    },
  ],
  controllers: [{ type: 'VirtualLsiLogicController', key: 1000 }],
  cluster: 'Foreman_Cluster',
};

export const state2 = {
  config: {
    datastoresUrl: '/api/v2/compute_resources/1/available_storage_domains',
    storagePodsUrl: '/api/v2/compute_resources/1/available_storage_pods',
    controllerTypes,
    diskModeTypes: defaultDiskModeTypes,
    paramsScope: 'abc',
  },
  controllers: [
    {
      type: 'VirtualLsiLogicController',
      sharedBus: 'noSharing',
      unitNumber: 7,
      key: 1000,
    },
  ],
  volumes: [
    {
      thin: true,
      name: 'Hard disk 1',
      mode: 'persistent',
      controllerKey: 1000,
      serverId: '502e324d-a2af-108b-1e10-b6d9eddfc53a',
      datastore: 'MyDatastore',
      id: '6000C297-9a11-998a-fc7c-8125ce9042a3',
      filename:
        '[Local-Ironforge] wanda-marcial.www.somedomain.com/wanda-marcial.www.somedomain.com.vmdk',
      sizeGb: 10,
      key: 2000,
      unitNumber: 0,
    },
  ],
  cluster: 'Foreman_Cluster',
};

export const clone = {
  config: {
    datastoresUrl: '/api/v2/compute_resources/1/available_storage_domains',
    storagePodsUrl: '/api/v2/compute_resources/1/available_storage_pods',
    vmExists: false,
    controllerTypes,
    diskModeTypes: {
      persistent: '»Persistent«',
      independent_persistent: '»Independent - Persistent«',
      independent_nonpersistent: '»Independent - Nonpersistent«',
    },
  },
  volumes: [
    {
      thin: true,
      name: 'Hard disk 1',
      mode: 'persistent',
      controllerKey: 1000,
      serverId: '500478d2-0c9b-3652-a378-b7703858a3c8',
      datastore: 'MyDatastore',
      id: '6000C293-d882-595d-670c-836daa2a2aa4',
      filename: '[MyDatastore] alton-buttner.example.com/alton-buttner.example.com.vmdk',
      size: 13631488,
      key: 2000,
      unitNumber: 0,
      sizeGb: 13,
    },
    {
      thin: false,
      name: 'Hard disk 2',
      mode: 'persistent',
      controllerKey: 1001,
      serverId: '500478d2-0c9b-3652-a378-b7703858a3c8',
      datastore: 'MyDatastore',
      id: '6000C292-ca02-a2e7-c868-fe8f86d66ae8',
      filename: '[MyDatastore] alton-buttner.example.com/alton-buttner.example.com_1.vmdk',
      size: 11534336,
      key: 2016,
      unitNumber: 0,
      sizeGb: 11,
    },
    {
      thin: false,
      name: 'Hard disk 3',
      mode: 'persistent',
      controllerKey: 1001,
      serverId: '500478d2-0c9b-3652-a378-b7703858a3c8',
      datastore: 'MyDatastore',
      id: '6000C294-4706-a370-4f30-8022353519ba',
      filename: '[MyDatastore] alton-buttner.example.com/alton-buttner.example.com_2.vmdk',
      size: 1048576,
      key: 2017,
      unitNumber: 1,
      sizeGb: 1,
    },
  ],
  controllers: [
    {
      type: 'VirtualLsiLogicController',
      key: 1000,
    },
    {
      type: 'VirtualLsiLogicController',
      key: 1001,
    },
  ],
  cluster: 'Foreman_Cluster',
};

export const emptyState = {
  config: {
    datastoresUrl: '/api/v2/compute_resources/1/available_storage_domains',
    storagePodsUrl: '/api/v2/compute_resources/1/available_storage_pods',
    controllerTypes,
    diskModeTypes: defaultDiskModeTypes,
  },
  volumes: [],
  controllers: [],
  cluster: null,
};
