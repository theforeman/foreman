/* eslint-disable */

export const props = {
  id: 'f219e02d-68c5-2669-a641-d7bf45476dd0',
  config: {
    controllerTypes: {
      VirtualBusLogicController: 'Bus Logic Parallel',
      VirtualLsiLogicController: 'LSI Logic Parallel',
      VirtualLsiLogicSASController: 'LSI Logic SAS',
      ParaVirtualSCSIController: 'VMware Paravirtual'
    },
    diskModeTypes: {
      persistent: 'Persistent',
      independent_persistent: 'Independent - Persistent',
      independent_nonpersistent: 'Independent - Nonpersistent'
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
      vsanDatastore: 'vsanDatastore (free: 207 GB, prov: 26.1 GB, total: 233 GB)'
    }
  },
  thin: true,
  name: 'Hard disk',
  mode: 'persistent',
  controllerKey: 1000,
  sizeGb: 10,
  key: 'f219e02d-68c5-2669-a641-d7bf45476dd0',
  removeDisk: () => {},
  updateDisk: () => {}
};
