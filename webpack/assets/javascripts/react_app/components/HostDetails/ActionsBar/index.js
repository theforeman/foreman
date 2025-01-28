import PropTypes from 'prop-types';
import React, { useState, createContext } from 'react';
import { useSelector, shallowEqual, useDispatch } from 'react-redux';
import {
  Button,
  DropdownItem,
  Dropdown,
  DropdownSeparator,
  KebabToggle,
  Split,
  SplitItem,
} from '@patternfly/react-core';
import {
  DatabaseIcon,
  TrashIcon,
  CloneIcon,
  UndoIcon,
  BuildIcon,
  TerminalIcon,
} from '@patternfly/react-icons';
import { visit } from '../../../../foreman_navigation';
import { translate as __ } from '../../../common/I18n';
import { selectKebabItems } from './Selectors';
import { foremanUrl } from '../../../common/helpers';
import { cancelBuild, deleteHost, isHostTurnOn } from './actions';
import {
  useForemanSettings,
  useForemanHostsPageUrl,
} from '../../../Root/Context/ForemanContext';
import BuildModal from './BuildModal';
import Slot from '../../common/Slot';

import forceSingleton from '../../../common/forceSingleton';

export const ForemanActionsBarContext = forceSingleton(
  'ActionsBarContext',
  () => createContext()
);

const ActionsBar = ({
  hostId,
  hostFriendlyId,
  hostName,
  computeId,
  isBuild,
  permissions: {
    destroy_hosts: canDestroy,
    create_hosts: canCreate,
    edit_hosts: canEdit,
    build_hosts: canBuild,
  },
}) => {
  const [kebabIsOpen, setKebab] = useState(false);
  const [isBuildModalOpen, setBuildModal] = useState(false);
  const onKebabToggle = isOpen => setKebab(isOpen);
  const { destroyVmOnHostDelete } = useForemanSettings();
  const hostsIndexUrl = useForemanHostsPageUrl();
  const registeredItems = useSelector(selectKebabItems, shallowEqual);
  const isHostActive = useSelector(isHostTurnOn);

  const dispatch = useDispatch();
  const deleteHostHandler = () =>
    dispatch(
      deleteHost(hostName, computeId, destroyVmOnHostDelete, hostsIndexUrl)
    );

  const isConsoleDisabled = !(computeId && isHostActive);
  const determineTooltip = () => {
    if (isConsoleDisabled) {
      if (computeId) {
        return __('Console disabled as the host is powered off.');
      }
      return __('Compute resource does not support the console function.');
    }
    return undefined;
  };
  const buildHandler = () => {
    if (isBuild) {
      dispatch(cancelBuild(hostId, hostName));
      setKebab(false);
    } else {
      setBuildModal(true);
    }
  };
  const dropdownItems = [
    <DropdownItem
      ouiaId="build-dropdown-item"
      onClick={buildHandler}
      key="build"
      component="button"
      isDisabled={!canBuild}
      icon={<BuildIcon />}
    >
      {isBuild ? __('Cancel build') : __('Build')}
    </DropdownItem>,
    <DropdownItem
      ouiaId="clone-dropdown-item"
      isDisabled={!canCreate}
      onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/clone`))}
      key="clone"
      component="button"
      icon={<CloneIcon />}
    >
      {__('Clone')}
    </DropdownItem>,
    <DropdownItem
      ouiaId="delete-dropdown-item"
      isDisabled={!canDestroy}
      onClick={deleteHostHandler}
      key="delete"
      component="button"
      icon={<TrashIcon />}
    >
      {__('Delete')}
    </DropdownItem>,
    <DropdownSeparator key="sp-1" ouiaId="dropdown-separator-1" />,
    <DropdownItem
      ouiaId="console-dropdown-item"
      onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/console`))}
      key="console"
      isAriaDisabled={isConsoleDisabled}
      tooltip={determineTooltip()}
      component="button"
      icon={<TerminalIcon />}
    >
      {__('Console')}
    </DropdownItem>,
    <DropdownItem
      ouiaId="fact-dropdown-item"
      onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/facts`))}
      key="fact"
      component="button"
      icon={<DatabaseIcon />}
    >
      {__('Facts')}
    </DropdownItem>,
    <DropdownSeparator key="sp-2" ouiaId="dropdown-separator-2" />,
    <DropdownItem
      ouiaId="pre-version-dropdown-item"
      icon={<UndoIcon />}
      href={`/hosts/${hostFriendlyId}`}
      key="prev-version"
    >
      {__('Legacy UI')}
    </DropdownItem>,
  ];

  return (
    <>
      <Split hasGutter>
        <SplitItem>
          <Slot hostId={hostId} hostName={hostName} id="_rex-host-features" />
        </SplitItem>
        <SplitItem>
          <Button
            ouiaId="host-edit-button"
            onClick={() => visit(foremanUrl(`/hosts/${hostFriendlyId}/edit`))}
            variant="secondary"
            isDisabled={!canEdit}
          >
            {__('Edit')}
          </Button>
          <ForemanActionsBarContext.Provider value={{ onKebabToggle }}>
            <Dropdown
              ouiaId="kebab-dropdown"
              alignments={{ default: 'right' }}
              toggle={
                <KebabToggle id="hostdetails-kebab" onToggle={onKebabToggle} />
              }
              isOpen={kebabIsOpen}
              isPlain
              dropdownItems={dropdownItems.concat(registeredItems)}
            />
          </ForemanActionsBarContext.Provider>
        </SplitItem>
      </Split>
      {isBuildModalOpen && (
        <BuildModal
          isModalOpen={isBuildModalOpen}
          onClose={() => setBuildModal(false)}
          hostFriendlyId={hostFriendlyId}
          hostName={hostName}
        />
      )}
    </>
  );
};

ActionsBar.propTypes = {
  hostId: PropTypes.number,
  hostFriendlyId: PropTypes.string,
  hostName: PropTypes.string,
  computeId: PropTypes.number,
  permissions: PropTypes.object,
  isBuild: PropTypes.bool,
};
ActionsBar.defaultProps = {
  hostId: undefined,
  hostFriendlyId: undefined,
  hostName: undefined,
  computeId: undefined,
  permissions: {
    destroy_hosts: false,
    create_hosts: false,
    edit_hosts: false,
    build_hosts: false,
  },
  isBuild: false,
};

export default ActionsBar;
