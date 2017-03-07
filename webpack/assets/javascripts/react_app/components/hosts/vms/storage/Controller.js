import React from 'react';
import VMStorageActions from '../../../../actions/VMStorageActions';
import { VMStorageVMWare } from '../../../../constants';
import { Button } from 'react-bootstrap';
import Disk from './Disk';
import Select from '../../../common/forms/Select';

class Controller extends React.Component {
  constructor(props) {
    super(props);
  }

  disks() {
    return this.props.disks.map((disk, index) => {
      return (<Disk
        key={index}
        id={index}
        controllerId={this.props.position}
        datastores={this.props.defaults.datastores}
        storagePods={this.props.defaults.storage_pods}
        {...disk}
      />);
    });
  }

  componentDidMount() {
    if (this.props.disks.length === 0) { this.addDisk(this.props.position); }
  }

  addDisk(controllerPosition, e) {
    VMStorageActions.addDisk(controllerPosition);
  }

  removeDisk(controllerPosition, e) {
    VMStorageActions.removeDisk(controllerPosition);
  }

  controllerUpdated(attribute, e) {
    const value = e.target.value;
    let attributes = {};

    attributes[attribute] = value;
    VMStorageActions.updateController(this.props.position, attributes);
  }

  selectableTypes() {
    return Object.entries(VMStorageVMWare.ControllerTypes).map((attribute) => {
      return (<option key={attribute[0]} value={attribute[0]}>{attribute[1]}</option>);
    });
  }

  removeController(id, e) {
    VMStorageActions.removeController(id);
  }

  render() {
    return (
      <div>
      <div className="fields removable-item">
        <Select
          label={__('Create SCSI controller')}
          value={this.props.type}
          onChange={this.controllerUpdated.bind(this, 'type')}
          options={this.selectableTypes()}
        />
        {this.disks()}
      </div>
        <div className="right">
          <Button
            disabled={this.props.disks.length >= VMStorageVMWare.MaxDisksPerController}
            onClick={this.addDisk.bind(this, this.props.position)}>
            {__('Add volume')}
          </Button>
          <Button
            onClick={this.removeController.bind(this, this.props.position)}
            bsClass="btn btn-danger remove"
            bsStyle="danger">
            {__('Remove controller')}
          </Button>
        </div>
    </div>
    );
  }
}

export default Controller;
