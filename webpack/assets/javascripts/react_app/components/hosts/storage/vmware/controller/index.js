import { Button } from 'patternfly-react';
import React from 'react';
import PropTypes from 'prop-types';

import Select from '../../../../common/forms/Select';

import Disk from './disk';
import { translate as __ } from '../../../../../../react_app/common/I18n';
import { noop } from '../../../../../common/helpers';
import './controller.scss';

const Controller = ({
  addDiskEnabled,
  addDisk,
  removeDisk,
  updateController,
  updateDisk,
  controller,
  controllerVolumes,
  removeController,
  config,
}) => {
  const getEventValue = e => {
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

  const disks = () =>
    controllerVolumes.map(disk => (
      <Disk
        key={disk.key}
        id={disk.key}
        updateDisk={(attribute, e) => _updateDisk(disk.key, attribute, e)}
        removeDisk={() => removeDisk(disk.key)}
        config={config}
        {...disk}
      />
    ));

  return (
    <div className="controller-container">
      <div className="controller-header">
        <div className="control-label col-md-2 controller-selected-container">
          <label>{__('Create SCSI controller')}</label>
        </div>
        <div className="controller-type-container col-md-4">
          <Select
            value={controller.type}
            disabled={config.vmExists}
            onChange={e => _updateController('type', e)}
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
      <div className="disks-container">{disks()}</div>
    </div>
  );
};

Controller.propTypes = {
  config: PropTypes.object.isRequired,
  controller: PropTypes.object.isRequired,
  controllerVolumes: PropTypes.array,
  addDiskEnabled: PropTypes.bool,
  addDisk: PropTypes.func,
  removeDisk: PropTypes.func,
  updateController: PropTypes.func,
  updateDisk: PropTypes.func,
  removeController: PropTypes.func,
};

Controller.defaultProps = {
  controllerVolumes: [],
  addDiskEnabled: false,
  addDisk: noop,
  removeDisk: noop,
  updateController: noop,
  updateDisk: noop,
  removeController: noop,
};

export default Controller;
