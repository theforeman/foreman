/* eslint-disable camelcase, no-mixed-operators, no-param-reassign */
import {
  Button,
  Divider,
  Flex,
  FlexItem,
  Tooltip,
} from '@patternfly/react-core';
import { PlusCircleIcon, TrashIcon } from '@patternfly/react-icons';
import { SimpleSelect } from '@patternfly/react-templates';
import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { number_to_human_size } from 'number_helpers';

import Disk from './disk';
import {
  sprintf,
  translate as __,
} from '../../../../../../react_app/common/I18n';
import { noop } from '../../../../../common/helpers';
import { MaxDisksPerController } from '../StorageContainer.consts';

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
  const getEventValue = e => {
    if (!e || !e.target) {
      return e;
    }
    return e.target.type === 'checkbox' ? e.target.checked : e.target.value;
  };

  const _updateController = (attribute, e) => {
    updateController({ [attribute]: getEventValue(e) });
  };

  const humanSize = number => number_to_human_size(number, { precision: 2 });

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
    controllerVolumes.map((disk, index) => (
      <Disk
        key={disk.key}
        id={disk.key}
        volumeNumber={index + 1}
        defaultExpanded={
          config.vmExists ||
          index === 0 ||
          index === controllerVolumes.length - 1
        }
        updateDisk={(attribute, e) => {
          updateDisk(disk.key, { [attribute]: e });
        }}
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

  const controllerTypeOptions = useMemo(
    () =>
      Object.entries(config.controllerTypes).map(([key, value]) => ({
        content: value,
        value: key,
        selected: key === controller.type,
      })),
    [config.controllerTypes, controller.type]
  );

  const hasVolumes = controllerVolumes.length > 0;
  const addVolumeDisabled = !addDiskEnabled || config.vmExists;

  let addVolumeTooltip = '';
  if (config.vmExists) {
    addVolumeTooltip = __('Cannot add volumes to an existing VM');
  } else if (!addDiskEnabled) {
    addVolumeTooltip = sprintf(
      __('Maximum number of disks (%s) has been reached'),
      MaxDisksPerController
    );
  }

  return (
    <div className="controller-container">
      <Flex
        alignItems={{ default: 'alignItemsCenter' }}
        className="controller-header"
      >
        <FlexItem>
          <b>{__('Controller')}</b>
        </FlexItem>
        <FlexItem>
          <SimpleSelect
            ouiaId="select-controller-type"
            initialOptions={controllerTypeOptions}
            isDisabled={config.vmExists}
            onSelect={(_ev, selection) => _updateController('type', selection)}
          />
        </FlexItem>
        <FlexItem align={{ default: 'alignRight' }}>
          <Button
            variant="link"
            icon={<TrashIcon />}
            onClick={removeController}
            isDisabled={config.vmExists}
            ouiaId="btn-remove-controller"
            aria-label={__('Remove controller')}
          >
            {__('Remove')}
          </Button>
        </FlexItem>
      </Flex>
      <div className="disks-container">
        {disks()}
        {hasVolumes && <Divider className="volume-divider" />}
        {addVolumeDisabled ? (
          <Tooltip content={addVolumeTooltip}>
            <Button
              variant="link"
              icon={<PlusCircleIcon />}
              className="btn-add-disk"
              isAriaDisabled
              ouiaId="btn-add-disk"
            >
              {hasVolumes ? __('Add another volume') : __('Add volume')}
            </Button>
          </Tooltip>
        ) : (
          <Button
            variant="link"
            icon={<PlusCircleIcon />}
            className="btn-add-disk"
            onClick={addDisk}
            ouiaId="btn-add-disk"
          >
            {hasVolumes ? __('Add another volume') : __('Add volume')}
          </Button>
        )}
      </div>
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
      datacenter: PropTypes.string,
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
