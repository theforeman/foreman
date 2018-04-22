/* eslint-disable */

export const vmwareData = {
  config: {
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual',
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent',
    },
    storagePods: { StorageCluster: 'StorageCluster (free: 1.01 TB, prov: 7.49 TB, total: 8.5 TB)' },
    datastores: {
      'cfme-esx-55-01-local': 'cfme-esx-55-01-local (free: 524 GB, prov: 465 GB, total: 924 GB)',
      'cfme-esx-55-03-local': 'cfme-esx-55-03-local (free: 898 GB, prov: 165 GB, total: 924 GB)',
      'cfme-esx-55-04-local': 'cfme-esx-55-04-local (free: 250 GB, prov: 681 GB, total: 924 GB)',
      'cfme-esx-55-na01a': 'cfme-esx-55-na01a (free: 448 GB, prov: 8.56 TB, total: 4 TB)',
      'cfme-esx-55-na01b': 'cfme-esx-55-na01b (free: 587 GB, prov: 7.25 TB, total: 4.5 TB)',
      'cfme-esx-admin-lun-na01b':
        'cfme-esx-admin-lun-na01b (free: 553 GB, prov: 519 GB, total: 1020 GB)',
      'cfme-esx-glob-na01a-s':
        'cfme-esx-glob-na01a-s (free: 1.45 TB, prov: 3.49 TB, total: 1.9 TB)',
      'cfme-esx-glob-na01b-s':
        'cfme-esx-glob-na01b-s (free: 1.37 TB, prov: 2.22 TB, total: 1.9 TB)',
      'cfme-iso-glob-na01a-s': 'cfme-iso-glob-na01a-s (free: 341 GB, prov: 134 GB, total: 475 GB)',
      'do-not-use-datastore': 'do-not-use-datastore (free: 462 GB, prov: 12.6 GB, total: 475 GB)',
      'do-not-use-host-prov': 'do-not-use-host-prov (free: 0 Bytes, prov: 973 MB, total: 973 MB)',
      master_iso_rdu: 'master_iso_rdu (free: 689 GB, prov: 289 GB, total: 973 GB)',
      temp_store: 'temp_store (free: 475 GB, prov: 19.5 MB, total: 475 GB)',
      vsanDatastore: 'vsanDatastore (free: 207 GB, prov: 26.1 GB, total: 233 GB)',
    },
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
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual',
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent',
    },
    storagePods: {
      StorageCluster: 'StorageCluster (free: 1.01 TB, prov: 7.49 TB, total: 8.5 TB)',
    },
    datastores: {
      'org-esx-55-01-local': 'org-esx-55-01-local (free: 524 GB, prov: 465 GB, total: 924 GB)',
      'org-esx-55-03-local': 'org-esx-55-03-local (free: 898 GB, prov: 165 GB, total: 924 GB)',
      'org-esx-55-04-local': 'org-esx-55-04-local (free: 250 GB, prov: 681 GB, total: 924 GB)',
      'org-esx-55-na01a': 'org-esx-55-na01a (free: 448 GB, prov: 8.56 TB, total: 4 TB)',
      'org-esx-55-na01b': 'org-esx-55-na01b (free: 587 GB, prov: 7.25 TB, total: 4.5 TB)',
      'org-esx-admin-lun-na01b':
        'org-esx-admin-lun-na01b (free: 553 GB, prov: 519 GB, total: 1020 GB)',
      'org-esx-glob-na01a-s': 'org-esx-glob-na01a-s (free: 1.45 TB, prov: 3.49 TB, total: 1.9 TB)',
      'org-esx-glob-na01b-s': 'org-esx-glob-na01b-s (free: 1.37 TB, prov: 2.22 TB, total: 1.9 TB)',
      'org-iso-glob-na01a-s': 'org-iso-glob-na01a-s (free: 341 GB, prov: 134 GB, total: 475 GB)',
      'do-not-use-datastore': 'do-not-use-datastore (free: 462 GB, prov: 12.6 GB, total: 475 GB)',
      'do-not-use-host-prov': 'do-not-use-host-prov (free: 0 Bytes, prov: 973 MB, total: 973 MB)',
      master_iso: 'master_iso (free: 689 GB, prov: 289 GB, total: 973 GB)',
      temp_store: 'temp_store (free: 475 GB, prov: 19.5 MB, total: 475 GB)',
      vsanDatastore: 'vsanDatastore (free: 207 GB, prov: 26.1 GB, total: 233 GB)',
    },
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
};

export const state2 = {
  config: {
    datastoresUrl: '/api/v2/compute_resources/1/available_storage_domains',
    storagePodsUrl: '/api/v2/compute_resources/1/available_storage_pods',
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual',
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent',
    },
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
};

export const clone = {
  config: {
    datastoresUrl: '/api/v2/compute_resources/1/available_storage_domains',
    storagePodsUrl: '/api/v2/compute_resources/1/available_storage_pods',
    vmExists: false,
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual',
    },
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
};

export const emptyState = {
  config: {
    datastoresUrl: '/api/v2/compute_resources/1/available_storage_domains',
    storagePodsUrl: '/api/v2/compute_resources/1/available_storage_pods',
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual',
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent',
    },
  },
  volumes: [],
  controllers: [],
};
