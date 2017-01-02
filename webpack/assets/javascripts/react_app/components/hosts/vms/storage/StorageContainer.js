import React from 'react';
import helpers from '../../../../common/helpers';
import { Button } from 'react-bootstrap';
import Controller from './Controller';
import VMStorageStore from '../../../../stores/VMStorageStore';
import VMStorageActions from '../../../../actions/VMStorageActions';
import { VMStorageVMWare } from '../../../../constants';

class StorageContainer extends React.Component {
  constructor(props) {
    super(props);
    this.state = { controllers: VMStorageStore.getControllers() };
    helpers.bindMethods(this, [
      'onChange', 'onError',
      'addController', 'removeController'
    ]);
  }
  componentDidMount() {
    VMStorageStore.addChangeListener(this.onChange);
    VMStorageStore.addErrorListener(this.onError);
    this.loadDefaultController();

  }

  componentWillUnmount() {
    VMStorageStore.removeChangeListener(this.onChange);
    VMStorageStore.removeErrorListener(this.onError);
  }

  onChange(event) {
    this.setState({ controllers: VMStorageStore.getControllers() });
  }

  onError(info) {
    if (this.props.id === info.id) {
      this.setState({
        errorMessage: info.textStatus
      });
    }
  }

  addController(e = null) {
    VMStorageActions.addController({defaults: this.props.data});
  }

  removeController(currentPosition, e) {
    VMStorageActions.removeController(currentPosition);
  }

  loadDefaultController() {
    if (this.state.controllers.length === 0) { this.addController(); }
  }

  controllers() {
    return this.state.controllers.map((controller) => {
      return (<Controller
        key={controller.position}
        {...controller}
        />);
      });
    }

    format() {
      let data = {scsiControllers: [], volumes: []};

      this.state.controllers.forEach((controller) => {
        data.scsiControllers.push({key: controller.SCSIKey, type: controller.type});
        controller.disks.forEach((disk) => {
          let attributes = {sizeGb: disk.size,
             storagePod: disk.storagePod,
             thin: disk.thinProvision,
             datastore: disk.dataStore,
             eagerZero: disk.eagerZero,
             controllerKey: controller.SCSIKey,
             name: disk.name
           };

          data.volumes.push(attributes);
        });
      });
      return JSON.stringify(data);
    }

    render() {
      return (
        <div className="row">
          <fieldset id="storage_volumes">
            <legend>{__('Storage')}</legend>
            {this.controllers()}
          </fieldset>
          <div className="row fr">
            <div className="clearfix">
              <Button
                id="add-controller"
                onClick={this.addController}
                disabled={this.state.controllers.length >= VMStorageVMWare.MaxControllers} >
                Add Controller
              </Button>
            </div>
          </div>
          <input
            value={this.format()}
            name="host[compute_attributes][scsi_controllers]"
            hidden={true}
            readOnly={true}
          />
          <code>
            JSON:
            {JSON.stringify(this.format())}
          </code>
        </div>
      );
  }
}

export default StorageContainer;
