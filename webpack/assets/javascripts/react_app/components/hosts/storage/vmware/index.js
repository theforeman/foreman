import { pick } from 'lodash';
import React from 'react';
import { Alert, Button } from 'patternfly-react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

import Controller from './controller/';
import * as VmWareActions from '../../../../redux/actions/hosts/storage/vmware';
import { MaxDisksPerController } from './StorageContainer.consts';
import { translate as __ } from '../../../../../react_app/common/I18n';
import { noop } from '../../../../common/helpers';
import AlertBody from '../../../common/Alert/AlertBody';
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
    volumes: volumes.map((v) => filterKeyFromVolume(v)),
  });

class StorageContainer extends React.Component {
  componentDidMount() {
    const {
      data: { config, controllers, volumes, cluster },
      initController,
    } = this.props;

    initController(config, cluster, controllers, volumes);
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
      const controllerVolumes = volumes.filter(
        (v) => v.controllerKey === controller.key
      );

      return (
        <Controller
          key={controller.key}
          removeController={() => removeController(controller.key)}
          controller={controller}
          controllerVolumes={controllerVolumes}
          addDiskEnabled={controllerVolumes.length < MaxDisksPerController}
          addDisk={() => addDisk(controller.key)}
          updateDisk={updateDisk}
          removeDisk={removeDisk}
          updateController={(newValues) => updateController(idx, newValues)}
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
    const { addController, controllers, volumes, cluster, config } = this.props;
    const paramsScope = config && config.paramsScope;
    const enableAddControllerBtn =
      config && config.addControllerEnabled && !config.vmExists;

    if (!cluster) {
      return (
        <Alert type="info">
          <AlertBody message={__('Please select a cluster')} />
        </Alert>
      );
    }

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
  data: PropTypes.shape({
    config: PropTypes.object.isRequired,
    controllers: PropTypes.array.isRequired,
    volumes: PropTypes.array.isRequired,
    cluster: PropTypes.string,
  }).isRequired,
  controllers: PropTypes.array.isRequired,
  config: PropTypes.object,
  volumes: PropTypes.array,
  cluster: PropTypes.string,
  datastoresLoading: PropTypes.bool,
  datastores: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string,
      name: PropTypes.string,
      capacity: PropTypes.number,
      freespace: PropTypes.number,
      uncommitted: PropTypes.number,
    })
  ),
  datastoresError: PropTypes.string,
  storagePodsLoading: PropTypes.bool,
  storagePods: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.string,
      name: PropTypes.string,
      capacity: PropTypes.number,
      freespace: PropTypes.number,
    })
  ),
  storagePodsError: PropTypes.string,
  addController: PropTypes.func,
  addDisk: PropTypes.func,
  updateController: PropTypes.func,
  removeDisk: PropTypes.func,
  updateDisk: PropTypes.func,
  removeController: PropTypes.func,
  initController: PropTypes.func,
};

StorageContainer.defaultProps = {
  config: {},
  cluster: '',
  volumes: [],
  datastoresLoading: false,
  storagePodsLoading: false,
  datastores: [],
  storagePods: [],
  datastoresError: undefined,
  storagePodsError: undefined,
  addController: noop,
  addDisk: noop,
  updateController: noop,
  removeDisk: noop,
  updateDisk: noop,
  removeController: noop,
  initController: noop,
};

const mapStateToProps = (state) =>
  pick(state.hosts.storage.vmware, [
    'controllers',
    'config',
    'cluster',
    'volumes',
    'datastores',
    'datastoresLoading',
    'datastoresError',
    'storagePods',
    'storagePodsLoading',
    'storagePodsError',
  ]);

export default connect(mapStateToProps, VmWareActions)(StorageContainer);
