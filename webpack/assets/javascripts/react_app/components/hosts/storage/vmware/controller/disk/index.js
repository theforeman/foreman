import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  ExpandableSection,
  ExpandableSectionToggle,
  Flex,
  FlexItem,
  Button,
} from '@patternfly/react-core';
import { TrashIcon } from '@patternfly/react-icons';
import { translate as __ } from '../../../../../../../react_app/common/I18n';
import { vmwareDiskNameForIndex } from '../../../../../../redux/actions/hosts/storage/vmware.consts';
import { noop } from '../../../../../../common/helpers';
import DiskForm from './DiskForm';

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
  volumeNumber,
  defaultExpanded,
}) => {
  const [isExpanded, setIsExpanded] = useState(defaultExpanded);

  const volumeTitle =
    typeof name === 'string' && name.trim() !== ''
      ? name
      : vmwareDiskNameForIndex(volumeNumber);

  const toggleId = `volume-toggle-${volumeNumber}`;
  const contentId = `volume-content-${volumeNumber}`;

  return (
    <div className="disk-container">
      <Flex
        alignItems={{ default: 'alignItemsCenter' }}
        className="disk-header"
      >
        <FlexItem>
          <ExpandableSectionToggle
            isExpanded={isExpanded}
            onToggle={() => setIsExpanded(prev => !prev)}
            toggleId={toggleId}
            contentId={contentId}
          >
            {volumeTitle}
          </ExpandableSectionToggle>
        </FlexItem>
        <FlexItem>{`${sizeGb} GB`}</FlexItem>
        {!vmExists && (
          <FlexItem>
            <Button
              variant="link"
              icon={<TrashIcon />}
              onClick={removeDisk}
              ouiaId="btn-volume-delete"
              aria-label={__('Remove volume')}
            >
              {__('Remove')}
            </Button>
          </FlexItem>
        )}
      </Flex>
      <ExpandableSection
        isExpanded={isExpanded}
        isDetached
        isIndented
        toggleId={toggleId}
        contentId={contentId}
      >
        <DiskForm
          updateDisk={updateDisk}
          vmExists={vmExists}
          storagePod={storagePod}
          datastore={datastore}
          sizeGb={sizeGb}
          thin={thin}
          eagerZero={eagerZero}
          mode={mode}
          diskModeTypes={diskModeTypes}
          datastores={datastores}
          datastoresStatus={datastoresStatus}
          datastoresError={datastoresError}
          storagePods={storagePods}
          storagePodsStatus={storagePodsStatus}
          storagePodsError={storagePodsError}
        />
      </ExpandableSection>
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
  sizeGb: PropTypes.oneOfType([PropTypes.number, PropTypes.string]),
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
  volumeNumber: PropTypes.number,
  defaultExpanded: PropTypes.bool,
};

Disk.defaultProps = {
  name: '',
  storagePod: '',
  datastore: '',
  sizeGb: 1,
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
  volumeNumber: 1,
  defaultExpanded: false,
};

export default Disk;
