/* eslint-disable camelcase */
import React from 'react';
import Select from '../../../../../common/forms/Select';
import Checkbox from '../../../../../common/forms/Checkbox';
import NumericInput from '../../../../../common/forms/NumericInput';
import Button from '../../../../../common/forms/Button';
import Loader from '../../../../../common/Loader';
import MessageBox from '../../../../../common/MessageBox';

import './disk.scss';

const Disk = ({
  removeDisk,
  updateDisk,
  name,
  config: {
    storagePods, diskModeTypes, vmExists,
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
}) => {
  const datastoresSelect = (
  <Select
    disabled={vmExists}
    label={__('Data store')}
    value={datastore}
    onChange={updateDisk.bind(this, 'datastore')}
    options={datastores}
    allowClear="true"
    key="datastoresSelect"
  />
  );

  const datastoresErrorBox = (
  <MessageBox icontype="error-circle-o" msg={datastoresError} key="datastoresError" />
  );

  return (
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
    />}
    {!storagePod &&
    <Loader status={datastoresStatus} spinnerSize="sm">{[datastoresSelect, datastoresErrorBox]}</Loader>}

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
};

export default Disk;
