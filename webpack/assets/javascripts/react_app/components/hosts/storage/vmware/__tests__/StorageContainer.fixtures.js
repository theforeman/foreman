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