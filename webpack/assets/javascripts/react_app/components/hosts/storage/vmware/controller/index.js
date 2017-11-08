import { Button } from 'react-bootstrap';
import React from 'react';

import Select from '../../../../common/forms/Select';

import Disk from './disk';
import './controller.scss';

const Controller = ({
  addDiskEnabled,
  addDisk,
  removeDisk,
  updateController,
  updateDisk,
  ControllerTypes,
  controller,
  controllerVolumes,
  removeController,
  config,
}) => {
  const getEventValue = (e) => {
    if (!e.target) {
      return e;
    }
    return e.target.type === 'checkbox' ? e.target.checked : e.target.value;
  };

  const _updateController = (attribute, e) => {
    updateController({ [attribute]: getEventValue(e) });
  };

  const _updateDisk = (uuid, attribute, e) => {
    updateDisk(uuid, { [attribute]: getEventValue(e) });
  };

  const disks = () => controllerVolumes.map(disk => (
    <Disk
      key={disk.key}
      id={disk.key}
      updateDisk={_updateDisk.bind(this, disk.key)}
      removeDisk={removeDisk.bind(this, disk.key)}
      config={config}
      {...disk}
    />
  ));

  return (
    <div className="controller-container">
      <div className="controller-header">
        <div className="control-label col-md-2 controller-selected-container">
          <label>
            {__('Create SCSI controller')}
          </label>
        </div>
        <div className="controller-type-container col-md-4">
          <Select
            value={controller.type}
            disabled={config.vmExists}
            onChange={_updateController.bind(this, 'type')}
            options={config.controllerTypes}
          />
          <Button
            className="btn-add-disk"
            disabled={!addDiskEnabled || config.vmExists}
            onClick={addDisk}
          >
            {__('Add volume')}
          </Button>
        </div>
        <div className="delete-controller-container">
          <Button
            className="btn-remove-controller"
            onClick={removeController}
            disabled={config.vmExists}
          >
            {__('Delete Controller')}
          </Button>
        </div>
      </div>
      <div className="disks-container">
        {disks()}
      </div>
    </div>
  );
};

export default Controller;
