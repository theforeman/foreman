import React from 'react';
import VMStorageActions from '../../../../actions/VMStorageActions';
import { Button } from 'react-bootstrap';
import Select from '../../../common/forms/Select';
import Checkbox from '../../../common/forms/Checkbox';
import TextInput from '../../../common/forms/TextInput';

class Disk extends React.Component {
  constructor(props) {
    super(props);
  }

  removeDisk(event) {
    VMStorageActions.removeDisk(this.props.controllerId, this.props.id);
  }

  selectableStores() {
    return this.props.datastores.map((attribute) => {
      const key = Object.keys(attribute)[0];
      const value = Object.values(attribute)[0];

      return (<option key={key} value={key}>{value}</option>);
    });
  }

  selectablePods() {
    return this.props.storagePods.map((attribute) => {
      const key = Object.keys(attribute)[0];
      const value = Object.values(attribute)[0];

      return (<option key={key} value={key}>{value}</option>);
    });
  }

  updateDiskAttribute(attribute, event) {
    const value = event.target.value;
    let attributes = Object.assign({}, this.props);

    attributes[attribute] = value;
    VMStorageActions.updateDisk(this.props.controllerId, this.props.id, attributes);
  }

  updateDiskBooleanAttributes(attribute, event) {
    let attributes = Object.assign({}, this.props);

    attributes[attribute] = !this.props[attribute];
    VMStorageActions.updateDisk(this.props.controllerId, this.props.id, attributes);
  }

  render() {
    return (
      <div>
        <TextInput
          value={this.props.name}
          onChange={this.updateDiskAttribute.bind(this, 'name')}
          label={__('Disk name')}
        />

        <Select
          label={__('Storage Pod')}
          value={this.props.storagePod}
          onChange={this.updateDiskAttribute.bind(this, 'storagePod')}
          options={this.selectablePods()}
          />

        <Select
          label={__('Data store')}
          value={this.props.dataStore}
          onChange={this.updateDiskAttribute.bind(this, 'dataStore')}
          options={this.selectableStores()}
        />

        <TextInput
          value={this.props.size}
          onChange={this.updateDiskAttribute.bind(this, 'size')}
          label={__('Size (GB)')}
        />

        <Checkbox
          label={__('Thin provision')}
          checked={this.props.thinProvision}
          onChange={this.updateDiskBooleanAttributes.bind(this, 'thinProvision')}
        />

        <Checkbox
          label={__('Eager zero')}
          checked={this.props.eagerZero}
          onChange={this.updateDiskBooleanAttributes.bind(this, 'eagerZero')}
        />

        <Button
          onClick={this.removeDisk.bind(this)}
          bsStyle="warning">
          {__('Remove volume')}
        </Button>
      </div>
    );
  }
}

export default Disk;
