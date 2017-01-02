import AppDispatcher from '../dispatcher';
import { ACTIONS, VMStorageVMWare } from '../constants';
import AppEventEmitter from './AppEventEmitter';
import _ from 'lodash';

let _vmStorage = { controllers: [] };

class VMStorageEventEmitter extends AppEventEmitter {
  constructor() {
    super();
    const positions = [0, 1, 2, 3];

    for (let position of positions) {
      let attributes = Object.assign(
        {
          position: position,
          SCSIKey: VMStorageVMWare.InitialSCSIKey + position,
          disks: [],
          enabled: false
        },
      );

      _vmStorage.controllers.push(attributes);
    }
  }

  getControllers() {
    return _vmStorage.controllers.filter((ctrl) => { return ctrl.enabled === true; });
  }

  getControllersCount() {
    return this.getControllers().length;
  }
}

const VMStorageStore = new VMStorageEventEmitter();

const addController = (action) => {
  let ctrl = _vmStorage.controllers.find((ctl) => { return ctl.enabled === false; });

  ctrl.enabled = true;
  _.assign(ctrl, action.props, VMStorageVMWare.defaultConrollerAttributes);
  VMStorageStore.emitChange({id: ctrl.id});
};

const removeController = (action) => {
  const id = action.id;
  const ctrl = _vmStorage.controllers.find((ctl) => { return ctl.position === id; });

  ctrl.enabled = false;
  ctrl.disks = [];
  VMStorageStore.emitChange({id: id});
};

const updateController = (action) => {
  const id = action.id;
  const newAttributes = action.attributes;

  _vmStorage.controllers[id] = Object.assign(_vmStorage.controllers[id], newAttributes);
  VMStorageStore.emitChange({id: id});
};

const addVolume = (action) => {
  const id = action.controllerId;
  let controller = _vmStorage.controllers[id];

  controller.disks.push(Object.assign({}, VMStorageVMWare.defaultDiskAttributes));
  VMStorageStore.emitChange({id: id});
};

const removeVolume = (action) => {
  const controller = action.controllerId;
  const id = action.diskId;
  const disk = _vmStorage.controllers[controller].disks[id];

  _.pull(_vmStorage.controllers[controller].disks, disk);
  VMStorageStore.emitChange({id: controller});
};

const updateVolume = (action) => {
  const controller = action.controllerId;
  const disk = action.diskId;

  _vmStorage.controllers[controller].disks[disk] = action.attributes;
  VMStorageStore.emitChange({id: disk});
};

AppDispatcher.register(action => {
  switch (action.actionType) {
    case ACTIONS.CONTROLLER_ADDED: {
      addController(action);
      break;
    }
    case ACTIONS.CONTROLLER_REMOVED: {
      removeController(action);
      break;
    }
    case ACTIONS.CONTROLLER_UPDATED: {
      updateController(action);
      break;
    }
    case ACTIONS.DISK_ADDED: {
      addVolume(action);
      break;
    }
    case ACTIONS.DISK_REMOVED: {
      removeVolume(action);
      break;
    }
    case ACTIONS.DISK_UPDATED: {
      updateVolume(action);
      break;
    }
    default:
    break;
  }
});

export default VMStorageStore;
