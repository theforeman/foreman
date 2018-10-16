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
  config: { datastores, storagePods, diskModeTypes, vmExists },
  storagePod,
  datastore,
  sizeGb,
  thin,
  eagerzero,
  mode,
}) => (
  <div className="disk-container">
    <div className="form-group">
      <label className="col-md-2 control-label">{__('Disk name')}</label>
      <div className="col-md-4">{name}</div>
      <div className="col-md-2">
        {!vmExists && (
          <Button className="close" onClick={removeDisk}>
            <span aria-hidden="true">×</span>
          </Button>
        )}
      </div>
    </div>
    {!(datastore || datastore.length) && (
      <Select
        label={__('Storage Pod')}
        value={storagePod}
        disabled={vmExists}
        onChange={newValues => updateDisk('storagePod', newValues)}
        options={storagePods}
      />
    )}
    {!(storagePod && storagePod.length) && (
      <Select
        disabled={vmExists}
        label={__('Data store')}
        value={datastore}
        onChange={newValues => updateDisk('datastore', newValues)}
        options={datastores}
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
      disabled={vmExists}
      onChange={newValues => updateDisk('thin', newValues)}
    />

    <Checkbox
      label={__('Eager zero')}
      checked={eagerzero}
      disabled={vmExists}
      onChange={newValues => updateDisk('eagerzero', newValues)}
    />
  </div>
);

Disk.propTypes = {
  config: PropTypes.shape({
    datastores: PropTypes.object.isRequired,
    storagePods: PropTypes.object.isRequired,
    diskModeTypes: PropTypes.object.isRequired,
    vmExists: PropTypes.bool,
  }).isRequired,
  name: PropTypes.string,
  storagePod: PropTypes.string,
  datastore: PropTypes.string,
  sizeGb: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  thin: PropTypes.bool,
  eagerzero: PropTypes.bool,
  mode: PropTypes.string,
  removeDisk: PropTypes.func,
  updateDisk: PropTypes.func,
};

Disk.defaultProps = {
  name: '',
  storagePod: '',
  datastore: '',
  sizeGb: null,
  thin: false,
  eagerzero: false,
  mode: '',
  removeDisk: noop,
  updateDisk: noop,
};

export default Disk;
