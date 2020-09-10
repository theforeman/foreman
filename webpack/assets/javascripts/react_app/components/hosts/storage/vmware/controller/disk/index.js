import React from 'react';
import { Button } from 'patternfly-react';
import PropTypes from 'prop-types';
import Select from '../../../../../common/forms/Select';
import Checkbox from '../../../../../common/forms/Checkbox';
import NumericInput from '../../../../../common/forms/NumericInput';
import { translate as __ } from '../../../../../../../react_app/common/I18n';
import { noop } from '../../../../../../common/helpers';
import './disk.scss';

const Disk = ({
  removeDisk,
  updateDisk,
  name,
  config: { diskModeTypes, vmExists },
  storagePod,
  datastore,
  sizeGb,
  thin,
  eagerZero,
  mode,
  datastores,
  datastoresStatus,
  datastoresError,
  storagePods,
  storagePodsStatus,
  storagePodsError,
}) => {
  const updateStoragePod = newValues => {
    updateDisk('storagePod', newValues);
    updateDisk('datastore', { target: { value: null } });
  };
  const updateDatastore = newValues => {
    updateDisk('datastore', newValues);
    updateDisk('storagePod', { target: { value: null } });
  };

  return (
    <div className="disk-container">
      <div className="form-group">
        <label className="col-md-2 control-label">{__('Disk name')}</label>
        <div className="col-md-4">{name}</div>
        <div className="col-md-2">
          {!vmExists && (
            <Button className="close" onClick={removeDisk}>
              <span aria-hidden="true">&times;</span>
            </Button>
          )}
        </div>
      </div>
      {!(datastore && datastore.length) && (
        <Select
          label={__('Storage Pod')}
          value={storagePod}
          disabled={vmExists}
          onChange={newValues => updateStoragePod(newValues)}
          options={storagePods}
          allowClear
          key="storagePodsSelect"
          status={storagePodsStatus}
          errorMessage={storagePodsError}
          className="storage-pod"
        />
      )}
      {!(storagePod && storagePod.length) && (
        <Select
          disabled={vmExists}
          label={__('Data store')}
          value={datastore}
          onChange={newValues => updateDatastore(newValues)}
          options={datastores}
          allowClear
          key="datastoresSelect"
          status={datastoresStatus}
          errorMessage={datastoresError}
          className="datastore"
        />
      )}

      <Select
        label={__('Disk Mode')}
        value={mode}
        disabled={vmExists}
        onChange={newValues => updateDisk('mode', newValues)}
        options={diskModeTypes}
      />

      <NumericInput
        value={sizeGb}
        minValue={1}
        format={v => `${v} GB`}
        className="text-vmware-size"
        onChange={newValues => updateDisk('sizeGb', newValues)}
        label={__('Size (GB)')}
      />

      <Checkbox
        label={__('Thin provision')}
        checked={thin}
        disabled={vmExists || eagerZero}
        onChange={newValues => {
          updateDisk('thin', newValues);
          newValues && updateDisk('eagerZero', false);
        }}
      />

      <Checkbox
        label={__('Eager zero')}
        checked={eagerZero}
        disabled={vmExists || thin}
        onChange={newValues => {
          updateDisk('eagerZero', newValues);
          newValues && updateDisk('thin', false);
        }}
      />
    </div>
  );
};

Disk.propTypes = {
  config: PropTypes.shape({
    diskModeTypes: PropTypes.object,
    vmExists: PropTypes.bool,
  }).isRequired,
  name: PropTypes.string,
  storagePod: PropTypes.string,
  datastore: PropTypes.string,
  sizeGb: PropTypes.number,
  thin: PropTypes.bool,
  eagerZero: PropTypes.bool,
  mode: PropTypes.string,
  datastores: PropTypes.object,
  datastoresStatus: PropTypes.string,
  datastoresError: PropTypes.string,
  storagePods: PropTypes.object,
  storagePodsStatus: PropTypes.string,
  storagePodsError: PropTypes.string,
  removeDisk: PropTypes.func,
  updateDisk: PropTypes.func,
};

Disk.defaultProps = {
  name: '',
  storagePod: '',
  datastore: '',
  sizeGb: null,
  thin: false,
  eagerZero: false,
  mode: '',
  datastores: {},
  datastoresStatus: undefined,
  datastoresError: undefined,
  storagePods: {},
  storagePodsStatus: undefined,
  storagePodsError: undefined,
  removeDisk: noop,
  updateDisk: noop,
};

export default Disk;
