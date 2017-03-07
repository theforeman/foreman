export const ACTIONS = {
  RECEIVED_HOSTS_POWER_STATE: 'RECEIVED_HOSTS_POWER_STATE',
  HOSTS_REQUEST_ERROR: 'HOSTS_REQUEST_ERROR',
  RECEIVED_NOTIFICATIONS: 'RECEIVED_NOTIFICATIONS',
  NOTIFICATIONS_REQUEST_ERROR: 'NOTIFICATIONS_REQUEST_ERROR',
  NOTIFICATIONS_DRAWER_TOGGLE: 'NOTIFICATIONS_DRAWER_TOGGLE',
  NOTIFICATIONS_EXPAND_DRAWER_TAB: 'NOTIFICATIONS_EXPAND_DRAWER_TAB',
  NOTIFICATIONS_MARK_AS_READ: 'NOTIFICATIONS_MARK_AS_READ',
  NOTIFICATIONS_MARKED_AS_READ: 'NOTIFICATIONS_MARKED_AS_READ',
  NOTIFICATIONS_SET_REQUEST_STATUS: 'NOTIFICATIONS_SET_REQUEST_STATUS',
  CONTROLLER_ADDED: 'CONTROLLER_ADDED',
  CONTROLLER_REMOVED: 'CONTROLLER_REMOVED',
  DISK_ADDED: 'DISK_ADDED',
  DISK_REMOVED: 'DISK_REMOVED',
  DISK_UPDATED: 'DISK_UPDATED'
};

export const STATUS = {
  PENDING: 'PENDING',
  RESOLVED: 'RESOLVED',
  ERROR: 'ERROR'
};

export const ICON_CSS = {
  ok: 'pficon pficon-ok',
  success: 'pficon pficon-ok',
  info: 'pficon pficon-info',
  warning: 'pficon pficon-warning-triangle-o',
  error: 'pficon pficon-error-circle-o'
};

export const VMStorageVMWare = {
  ControllerTypes: {
    VirtualBusLogicController: 'Bus Logic Parallel',
    VirtualLsiLogicController: 'LSI Logic Parallel',
    VirtualLsiLogicSASController: 'LSI Logic SAS',
    ParaVirtualSCSIController: 'VMware Paravirtual'
  },
  MaxControllers: 4,
  defaultConrollerAttributes: {
    type: 'ParaVirtualSCSIController'
  },
  InitialSCSIKey: 1000,
  MaxDisksPerController: 15,
  defaultDiskAttributes: {
    size: '10',
    dataStore: '',
    storagePod: '',
    thinProvision: false,
    eagerZero: false,
    name: 'Hard disk'
  }
};
