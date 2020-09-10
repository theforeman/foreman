/* eslint-disable camelcase */
/* eslint-disable camelcase */
export const props = {
  controller: { type: 'VirtualLsiLogicController', key: 1000 },
  controllerVolumes: [
    {
      thin: true,
      name: 'Hard disk',
      mode: 'persistent',
      controllerKey: 1000,
      sizeGb: 10,
      key: 'e86728ee-dbde-ad59-13d6-0c5488635e73',
    },
  ],
  addDiskEnabled: true,
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
  },
  datastores: [
    {
      name: 'FC0001_LX_DC1_EXAMPLE_PROD_01',
      id: 'datastore-608634',
      capacity: 2199023255552,
      freespace: 380650913792,
      uncommitted: 3612356549242,
    },
  ],
  storagePods: [
    {
      name: 'LX-DC1-EXAMPLE',
      id: 'group-p859969',
      capacity: 5497021267968,
      freespace: 4756143603712,
    },
  ],
  addDisk: () => {},
  removeDisk: () => {},
  removeController: () => {},
  updateController: () => {},
  updateDisk: () => {},
};
