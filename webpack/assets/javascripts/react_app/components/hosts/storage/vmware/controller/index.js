/* eslint-disable camelcase, no-mixed-operators, no-param-reassign */
import { Button } from 'patternfly-react';
import React from 'react';
import PropTypes from 'prop-types';
import { number_to_human_size } from 'number_helpers';

import Select from '../../../../common/forms/Select';

import Disk from './disk';
import {
  sprintf,
  translate as __,
} from '../../../../../../react_app/common/I18n';
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
  datastores,
  datastoresStatus,
  datastoresError,
  storagePods,
  storagePodsStatus,
  storagePodsError,
}) => {
  const getEventValue = (e) => {
    if (!e || !e.target) {
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

  const humanSize = (number) => number_to_human_size(number, { precision: 2 });

  const datastoresStats = () => {
    if (!datastores.length) {
      return {};
    }
    return datastores.reduce((obj, d) => {
      obj[d.name] = sprintf(
        __('%(name)s (free: %(free)s, prov: %(prov)s, total: %(total)s)'),
        {
          name: d.name,
          free: humanSize(d.freespace),
          prov: humanSize(d.capacity + (d.uncommitted || 0) - d.freespace),
          total: humanSize(d.capacity),
        }
      );
      return obj;
    }, {});
  };

  const storagePodsStats = () => {
    if (!storagePods.length) {
      return {};
    }
    return storagePods.reduce((obj, s) => {
      obj[s.name] = sprintf(
        __('%(name)s (free: %(free)s, prov: %(prov)s, total: %(total)s)'),
        {
          name: s.name,
          free: humanSize(s.freespace),
          prov: humanSize(s.capacity - s.freespace),
          total: humanSize(s.capacity),
        }
      );
      return obj;
    }, {});
  };

  const disks = () =>
    controllerVolumes.map((disk) => (
      <Disk
        key={disk.key}
        id={disk.key}
        updateDisk={(attribute, e) => _updateDisk(disk.key, attribute, e)}
        removeDisk={() => removeDisk(disk.key)}
        config={config}
        datastores={datastoresStats()}
        datastoresStatus={datastoresStatus}
        datastoresError={datastoresError}
        storagePods={storagePodsStats()}
        storagePodsStatus={storagePodsStatus}
        storagePodsError={storagePodsError}
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
            onChange={(e) => _updateController('type', e)}
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
  addDiskEnabled: PropTypes.bool,
  controllerVolumes: PropTypes.array,
  datastores: PropTypes.arrayOf(
    PropTypes.exact({
      id: PropTypes.string,
      name: PropTypes.string,
      capacity: PropTypes.number,
      freespace: PropTypes.number,
      uncommitted: PropTypes.number,
    })
  ),
  datastoresStatus: PropTypes.string,
  datastoresError: PropTypes.string,
  storagePods: PropTypes.arrayOf(
    PropTypes.exact({
      id: PropTypes.string,
      name: PropTypes.string,
      capacity: PropTypes.number,
      freespace: PropTypes.number,
    })
  ),
  storagePodsStatus: PropTypes.string,
  storagePodsError: PropTypes.string,
  addDisk: PropTypes.func,
  removeDisk: PropTypes.func,
  updateController: PropTypes.func,
  updateDisk: PropTypes.func,
  removeController: PropTypes.func,
};

Controller.defaultProps = {
  addDiskEnabled: false,
  controllerVolumes: [],
  datastores: [],
  datastoresStatus: undefined,
  datastoresError: undefined,
  storagePods: [],
  storagePodsStatus: undefined,
  storagePodsError: undefined,
  addDisk: noop,
  removeDisk: noop,
  updateController: noop,
  updateDisk: noop,
  removeController: noop,
};

export default Controller;
