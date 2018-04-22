/* eslint-disable camelcase */
import React from 'react';
import { Button } from 'patternfly-react';
import PropTypes from 'prop-types';
import Select from '../../../../../common/forms/Select';
import Checkbox from '../../../../../common/forms/Checkbox';
import NumericInput from '../../../../../common/forms/NumericInput';
import { translate as __ } from '../../../../../../../react_app/common/I18n';
import './disk.scss';

const Disk = ({
  removeDisk,
  updateDisk,
  name,
  config: {
    diskModeTypes, vmExists,
  },
  storagePod,
  datastore,
  sizeGb,
  thin,
  eagerzero,
  mode,
  datastores,
  datastoresStatus,
  datastoresError,
  storagePods,
  storagePodsStatus,
  storagePodsError,
}) => (
  <div className="disk-container">
    <div className="form-group">
      <label className="col-md-2 control-label">
        {__('Disk name')}
      </label>
      <div className="col-md-4">
        {name}
      </div>
      <div className="col-md-2">
        {!vmExists &&
        <Button className="close" onClick={removeDisk}>
          <span aria-hidden="true">×</span>
        </Button>}
      </div>
    </div>
    {!datastore &&
    <Select
      label={__('Storage Pod')}
      value={storagePod}
      disabled={vmExists}
      onChange={updateDisk.bind(this, 'storagePod')}
      options={storagePods}
      allowClear="true"
      key="storagePodsSelect"
      status={storagePodsStatus}
      errorMessage={storagePodsError}
    />}
    {!storagePod &&
    <Select
      disabled={vmExists}
      label={__('Data store')}
      value={datastore}
      onChange={updateDisk.bind(this, 'datastore')}
      options={datastores}
      allowClear="true"
      key="datastoresSelect"
      status={datastoresStatus}
      errorMessage={datastoresError}
    />
    }

    <Select
      label={__('Disk Mode')}
      value={mode}
      disabled={vmExists}
      onChange={updateDisk.bind(this, 'mode')}
      options={diskModeTypes}
    />

    <NumericInput
      value={sizeGb}
      minValue={1}
      format={v => `${v} GB`}
      className="text-vmware-size"
      onChange={updateDisk.bind(this, 'sizeGb')}
      label={__('Size (GB)')}
    />

    <Checkbox
      label={__('Thin provision')}
      checked={thin}
      disabled={vmExists}
      onChange={updateDisk.bind(this, 'thin')}
    />

    <Checkbox
      label={__('Eager zero')}
      checked={eagerzero}
      disabled={vmExists}
      onChange={updateDisk.bind(this, 'eagerzero')}
    />
  </div>
);

Disk.propTypes = {
  removeDisk: PropTypes.func,
  updateDisk: PropTypes.func,
  name: PropTypes.string,
  config: PropTypes.shape({
    diskModeTypes: PropTypes.object,
    vmExists: PropTypes.bool,
  }),
  storagePod: PropTypes.string,
  datastore: PropTypes.string,
  sizeGb: PropTypes.number,
  thin: PropTypes.bool,
  eagerzero: PropTypes.bool,
  mode: PropTypes.string,
  datastores: PropTypes.object,
  datastoresStatus: PropTypes.string,
  datastoresError: PropTypes.string,
  storagePods: PropTypes.object,
  storagePodsStatus: PropTypes.string,
  storagePodsError: PropTypes.string,
};

export default Disk;
