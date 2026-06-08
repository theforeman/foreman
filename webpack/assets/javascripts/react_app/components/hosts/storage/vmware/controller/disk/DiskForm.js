import React, { useMemo } from 'react';
import PropTypes from 'prop-types';
import { Form, FormGroup, Checkbox, NumberInput } from '@patternfly/react-core';
import { TypeaheadSelect, SimpleSelect } from '@patternfly/react-templates';
import {
  translate as __,
  sprintf,
} from '../../../../../../../react_app/common/I18n';
import LabelIcon from '../../../../../../components/common/LabelIcon';
import FormStatus from './FormStatus';

const DiskForm = ({
  updateDisk,
  vmExists,
  storagePod,
  datastore,
  sizeGb,
  thin,
  eagerZero,
  mode,
  diskModeTypes,
  datastores,
  datastoresStatus,
  datastoresError,
  storagePods,
  storagePodsStatus,
  storagePodsError,
}) => {
  const updateStoragePod = newValues => {
    updateDisk('storagePod', newValues);
    updateDisk('datastore', null);
  };
  const updateDatastore = newValues => {
    updateDisk('datastore', newValues);
    updateDisk('storagePod', null);
  };

  const diskModeOptions = useMemo(
    () =>
      Object.entries(diskModeTypes).map(([key, value]) => ({
        content: value,
        value: key,
        selected: key === mode,
      })),
    [diskModeTypes, mode]
  );

  return (
    <Form isHorizontal className="disk-form">
      {!datastore?.length && (
        <FormGroup label={__('Storage Pod')} isRequired>
          <TypeaheadSelect
            toggleProps={{
              'aria-label': 'Storage pod select',
              ouiaId: 'select-storage-pod',
            }}
            selectOptions={Object.entries(storagePods || {}).map(
              ([key, value]) => ({
                content: value,
                value: key,
              })
            )}
            noOptionsFoundMessage={filter =>
              sprintf(__('No results found for %s'), filter)
            }
            onClearSelection={() => {
              updateStoragePod(null);
            }}
            onSelect={(_ev, selectedValue) => {
              updateStoragePod(selectedValue);
            }}
            selected={storagePod}
            className="storage-pod"
            key="storagePodsSelect"
            placeholder=""
            isDisabled={vmExists}
          />
          <FormStatus
            status={storagePodsStatus}
            errorMessage={storagePodsError}
            fieldName="storagePods"
          />
        </FormGroup>
      )}
      {!storagePod?.length && (
        <FormGroup label={__('Data store')} isRequired>
          <TypeaheadSelect
            toggleProps={{
              'aria-label': 'Data store select',
              ouiaId: 'select-datastore',
            }}
            isDisabled={vmExists}
            selectOptions={Object.entries(datastores || {}).map(
              ([key, value]) => ({
                content: value,
                value: key,
              })
            )}
            noOptionsFoundMessage={filter =>
              sprintf(__('No results found for %s'), filter)
            }
            onClearSelection={() => {
              updateDatastore(null);
            }}
            onSelect={(_ev, selectedValue) => {
              updateDatastore(selectedValue);
            }}
            selected={datastore}
            className="datastore"
            key="datastoresSelect"
            placeholder=""
          />
          <FormStatus
            status={datastoresStatus}
            errorMessage={datastoresError}
            fieldName="datastores"
          />
        </FormGroup>
      )}

      <FormGroup label={__('Disk mode')}>
        <SimpleSelect
          toggleWidth="80%"
          ouiaId="select-disk-mode"
          isDisabled={vmExists}
          onSelect={(_ev, selectedValue) => {
            updateDisk('mode', selectedValue);
          }}
          initialOptions={diskModeOptions}
        />
      </FormGroup>
      <FormGroup label={__('Size (GB)')}>
        <NumberInput
          value={sizeGb}
          min={1}
          className="text-vmware-size"
          onChange={event => {
            const newValue = event.target.value;
            if (newValue === '') {
              updateDisk('sizeGb', newValue);
            } else {
              const parsed = parseInt(newValue, 10) || 1;
              updateDisk('sizeGb', Math.max(1, parsed));
            }
          }}
          onPlus={() => updateDisk('sizeGb', (parseInt(sizeGb, 10) || 0) + 1)}
          onMinus={() => {
            const current = parseInt(sizeGb, 10);
            if (current > 1) {
              updateDisk('sizeGb', current - 1);
            }
          }}
          unit="GB"
          widthChars={10}
        />
      </FormGroup>
      <FormGroup
        hasNoPaddingTop
        label={__('Thin provision')}
        labelIcon={
          <LabelIcon
            text={__(
              'Allocates disk space on demand as data is written, rather than reserving the full size upfront. Saves storage space but may have slightly lower write performance on first access.'
            )}
          />
        }
      >
        <Checkbox
          ouiaId="checkbox-thin-provision"
          isChecked={thin}
          isDisabled={vmExists || eagerZero}
          onChange={(e, newValues) => {
            updateDisk('thin', newValues);
            newValues && updateDisk('eagerZero', false);
          }}
          id="checkbox-thin-provision"
        />
      </FormGroup>
      <FormGroup
        hasNoPaddingTop
        label={__('Eager zero')}
        labelIcon={
          <LabelIcon
            text={__(
              'Pre-allocates and zeros all disk blocks at creation time. Provides the best write performance but takes longer to create and reserves the full disk size immediately.'
            )}
          />
        }
      >
        <Checkbox
          ouiaId="checkbox-eager-zero"
          isChecked={eagerZero}
          isDisabled={vmExists || thin}
          onChange={(e, newValues) => {
            updateDisk('eagerZero', newValues);
            newValues && updateDisk('thin', false);
          }}
          id="checkbox-eager-zero"
        />
      </FormGroup>
    </Form>
  );
};

DiskForm.propTypes = {
  vmExists: PropTypes.bool,
  storagePod: PropTypes.string,
  datastore: PropTypes.string,
  sizeGb: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
  thin: PropTypes.bool,
  eagerZero: PropTypes.bool,
  mode: PropTypes.string,
  diskModeTypes: PropTypes.object,
  datastores: PropTypes.object,
  datastoresStatus: PropTypes.string,
  datastoresError: PropTypes.string,
  storagePods: PropTypes.object,
  storagePodsStatus: PropTypes.string,
  storagePodsError: PropTypes.string,
  updateDisk: PropTypes.func,
};

DiskForm.defaultProps = {
  vmExists: false,
  storagePod: '',
  datastore: '',
  sizeGb: 1,
  thin: false,
  eagerZero: false,
  mode: '',
  diskModeTypes: {},
  datastores: {},
  datastoresStatus: undefined,
  datastoresError: undefined,
  storagePods: {},
  storagePodsStatus: undefined,
  storagePodsError: undefined,
  updateDisk: () => {},
};

export default DiskForm;
