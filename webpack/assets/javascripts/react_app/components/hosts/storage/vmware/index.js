import React from 'react';
import { Button } from 'react-bootstrap';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

import Controller from './controller/';
import * as VmWareActions from '../../../../redux/actions/hosts/storage/vmware';
import { MaxDisksPerController } from './StorageContainer.consts';
import { translate as __ } from '../../../../../react_app/common/I18n';
import './StorageContainer.scss';
import { STATUS } from '../../../../constants';

const filterKeyFromVolume = (volume) => {
  // eslint-disable-next-line no-unused-vars
  const { key, ...volumeWithoutKey } = volume;
  return volumeWithoutKey;
};

export const controllersToJsonString = (controllers, volumes) =>
  JSON.stringify({
    scsiControllers: controllers,
    volumes: volumes.map(v => filterKeyFromVolume(v)),
  });

class StorageContainer extends React.Component {
  componentDidMount() {
    const {
      data: { config, controllers, volumes }, initController, fetchDatastores, fetchStoragePods,
    } = this.props;

    initController(config, controllers, volumes);
    fetchDatastores(config.datastoresUrl);
    fetchStoragePods(config.storagePodsUrl);
  }

  getDatastoresStatus() {
    const { datastoresLoading, datastoresError } = this.props;
    if (datastoresError) {
      return STATUS.ERROR;
    }
    if (datastoresLoading) {
      return STATUS.PENDING;
    }
    return STATUS.RESOLVED;
  }

  getStoragePodsStatus() {
    const { storagePodsLoading, storagePodsError } = this.props;
    if (storagePodsError) {
      return STATUS.ERROR;
    }
    if (storagePodsLoading) {
      return STATUS.PENDING;
    }
    return STATUS.RESOLVED;
  }

  renderControllers(controllers) {
    const {
      addDisk,
      updateController,
      removeDisk,
      updateDisk,
      removeController,
      config,
      volumes,
      datastores,
      datastoresError,
      storagePods,
      storagePodsError,
    } = this.props;

    return controllers.map((controller, idx) => {
      const controllerVolumes = volumes.filter(v => v.controllerKey === controller.key);

      return (
        <Controller
          key={controller.key}
          removeController={removeController.bind(this, controller.key)}
          controller={controller}
          controllerVolumes={controllerVolumes}
          addDiskEnabled={controllerVolumes.length < MaxDisksPerController}
          addDisk={addDisk.bind(this, controller.key)}
          updateDisk={updateDisk}
          removeDisk={removeDisk}
          updateController={updateController.bind(this, idx)}
          config={config}
          datastores={datastores}
          datastoresError={datastoresError}
          datastoresStatus={this.getDatastoresStatus()}
          storagePods={storagePods}
          storagePodsError={storagePodsError}
          storagePodsStatus={this.getStoragePodsStatus()}
        />
      );
    });
  }

  render() {
    const {
      addController, controllers, volumes, config,
    } = this.props;
    const paramsScope = config && config.paramsScope;
    const enableAddControllerBtn = config && config.addControllerEnabled && !config.vmExists;

    return (
      <div className="row vmware-storage-container">
        <div className="storage-header">
          <div className="col-md-2 storage-title">{__('Storage')}</div>
          <div className="col-md-10 storage-controller-buttons">
            <Button
              className="btn-add-controller"
              onClick={() => addController()}
              disabled={!enableAddControllerBtn}
              bsStyle="primary"
            >
              {__('Add Controller')}
            </Button>
          </div>
        </div>
        <div className="storage-body">
          {this.renderControllers(controllers)}
          <input
            value={controllersToJsonString(controllers, volumes)}
            id="scsi_controller_hidden"
            name={paramsScope}
            type="hidden"
          />
        </div>
      </div>
    );
  }
}

StorageContainer.propTypes = {
  addController: PropTypes.func.isRequired,
  addDisk: PropTypes.func.isRequired,
  config: PropTypes.object.isRequired,
  controllers: PropTypes.array,
  data: PropTypes.object,
  datastores: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
    capacity: PropTypes.number,
    freespace: PropTypes.number,
    uncommitted: PropTypes.number,
  })),
  datastoresError: PropTypes.string,
  fetchDatastores: PropTypes.func.isRequired,
  fetchStoragePods: PropTypes.func.isRequired,
  initController: PropTypes.func.isRequired,
  removeController: PropTypes.func.isRequired,
  removeDisk: PropTypes.func.isRequired,
  storagePods: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
    capacity: PropTypes.number,
    freespace: PropTypes.number,
  })),
  storagePodsError: PropTypes.string,
  updateController: PropTypes.func.isRequired,
  updateDisk: PropTypes.func.isRequired,
  volumes: PropTypes.array.isRequired,
};

StorageContainer.defaultProps = {
  volumes: [],
  config: {},
};

const mapDispatchToProps = (state) => {
  const {
    controllers, config, volumes, datastores, datastoresLoading, datastoresError,
    storagePods, storagePodsLoading, storagePodsError,
  } = state.hosts.storage.vmware;

  return {
    controllers,
    volumes,
    config,
    datastores,
    datastoresLoading,
    datastoresError,
    storagePods,
    storagePodsLoading,
    storagePodsError,
  };
};

export default connect(mapDispatchToProps, VmWareActions)(StorageContainer);
