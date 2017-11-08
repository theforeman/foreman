import React from 'react';
import { Button } from 'react-bootstrap';
import Controller from './controller/';
import { connect } from 'react-redux';
import * as VmWareActions from '../../../../redux/actions/hosts/storage/vmware';
import { MaxDisksPerController } from './StorageContainer.consts';
import './StorageContainer.scss';
import { omit } from 'lodash';

class StorageContainer extends React.Component {
  constructor(props) {
    super(props);
  }
  componentDidMount() {
    const {
      data: { config, controllers, volumes },
      initController,
    } = this.props;

    initController(config, controllers, volumes);
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
    } = this.props;

    return controllers.map((controller, idx) => {
      const controllerVolumes = volumes.filter(
        v => v.controllerKey === controller.key
      );

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
        />
      );
    });
  }

  render() {
    const { addController, controllers, volumes, config } = this.props;
    const paramsScope = config && config.paramsScope;
    const enableAddControllerBtn =
      config && config.addControllerEnabled && !config.vmExists;
    const controllersToJsonString = (controllers, volumes) =>
      JSON.stringify({
        scsiControllers: controllers,
        volumes: volumes.map(v => omit(v, 'key')),
      });

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

const mapDispatchToProps = state => {
  const { controllers, config, volumes = [] } = state.hosts.storage.vmware;

  return { controllers, volumes, config };
};

export default connect(mapDispatchToProps, VmWareActions)(StorageContainer);
